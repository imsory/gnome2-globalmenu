#include <config.h>

#include <glib.h>
#include "ipccommand.h"

typedef struct {
	GList * command_list;
	IPCCommand * current_command;
	gchar * current_prop;
	GString * current_prop_value;
	gchar * current_result;
	GString * current_result_value;
} ParseInfo;
static void start_element  (GMarkupParseContext *context, 
		const gchar * element_name, 
		const gchar **attribute_names, 
		const gchar **attribute_values, 
		ParseInfo    *pi, 
		GError      **error);
static void end_element  (GMarkupParseContext *context, 
		const gchar * element_name, 
		ParseInfo    *pi, 
		GError      **error);
static void text  (GMarkupParseContext *context, 
		const gchar *text,
		gsize text_len,
		ParseInfo    *pi, 
		GError      **error);
static void error  (GMarkupParseContext *context, 
		GError * error,
		ParseInfo *pi);

static GMarkupParser parser = {
	start_element,
	end_element,
	text,
	NULL,
	error,
};
static void start_element  (GMarkupParseContext *context, 
		const gchar * element_name, 
		const gchar **attribute_names, 
		const gchar **attribute_values, 
		ParseInfo    *pi, 
		GError      **error) {
	if(g_str_equal(element_name, "command")) {
		gint i;
		gchar * name = NULL;
		gchar * cid = NULL;
		for(i=0; attribute_names[i]; i++) {
			if(g_str_equal(attribute_names[i], "name")){
				name = g_strdup(attribute_values[i]);
			} else
			if(g_str_equal(attribute_names[i], "cid")){
				cid = g_strdup(attribute_values[i]);
			}
		}
		pi->current_command = ipc_command_new(cid, name);
	} else 
	if(g_str_equal(element_name, "p")){
		gint i;
		for(i=0; attribute_names[i]; i++) {
			if(g_str_equal(attribute_names[i], "name")){
				pi->current_prop = g_strdup(attribute_values[i]);
				pi->current_prop_value = g_string_new("");
				break;
			}
		}
	} else 
	if(g_str_equal(element_name, "r")){
		gint i;
		for(i=0; attribute_names[i]; i++) {
			if(g_str_equal(attribute_names[i], "name")){
				pi->current_result = g_strdup(attribute_values[i]);
				pi->current_result_value = g_string_new("");
				break;
			}
		}
	}
}
static void end_element  (GMarkupParseContext *context, 
		const gchar * element_name, 
		ParseInfo    *pi, 
		GError      **error) {
	if(g_str_equal(element_name, "p")) {
		g_datalist_set_data_full(&pi->current_command->parameters,
				pi->current_prop,
				g_string_free(pi->current_prop_value, FALSE), g_free);
		pi->current_prop = NULL;
		pi->current_prop_value = NULL;
	} else 
	if(g_str_equal(element_name, "r")) {
		g_datalist_set_data_full(&pi->current_command->results,
				pi->current_result,
				g_string_free(pi->current_result_value, FALSE), g_free);
		pi->current_result = NULL;
		pi->current_result_value = NULL;
	} else
	if(g_str_equal(element_name, "command")){
		pi->command_list = g_list_append(pi->command_list, pi->current_command);
		pi->current_command = NULL;
	}
}
static void text  (GMarkupParseContext *context, 
		const gchar *text,
		gsize text_len,
		ParseInfo    *pi, 
		GError      **error) {
	if(pi->current_prop) {
		g_string_append_len(pi->current_prop_value,
			   text, text_len);
	} else 
	if(pi->current_result) {
		g_string_append_len(pi->current_result_value,
			   text, text_len);
	}

}
static void error  (GMarkupParseContext *context, 
		GError * error,
		ParseInfo *pi) {
	g_warning("parsing error: %s", error->message);
}

IPCCommand * ipc_command_parse(const gchar * string){
	IPCCommand * rt = NULL;
	GList * list = ipc_command_list_parse(string);
	if(!list) {
		g_critical("paring failed");
		goto clean_up;
	}
	if(g_list_length(list)>1){
		g_critical("parsing a command list as a command!");
		GList * node;
		for(node = list; node; node=node->next){
			ipc_command_free(node->data);
		}
		goto clean_up;
	}
	rt = list->data;
clean_up:
	g_list_free(list);
	return rt;
}
GList * ipc_command_list_parse(const gchar * string) {
	ParseInfo cpi = {0};
	GMarkupParseContext * context;
	GError * error = NULL;
	context = g_markup_parse_context_new(&parser, 0, &cpi, NULL);
	if(g_markup_parse_context_parse(context, string, strlen(string), &error)){
	   	if(!cpi.command_list) {
			g_critical("parsing command failed");
			goto clean_up;
		}
		goto clean_up;
	}
	if(error) {
		/* FIXME: free any memory allocation in cpi*/
		g_critical("Parse command failed: %s", error->message);
		g_error_free(error);
		goto clean_up;
	}
clean_up:
	g_markup_parse_context_free(context);
	if(cpi.current_command) ipc_command_free(cpi.current_command);
	if(cpi.current_prop) g_free(cpi.current_prop);
	if(cpi.current_result) g_free(cpi.current_result);
	if(cpi.current_prop_value) g_string_free(cpi.current_prop_value, TRUE);
	if(cpi.current_result_value) g_string_free(cpi.current_result_value, TRUE);
	return cpi.command_list;
}
static void _to_string_foreach(GQuark key, gchar * value, gpointer foo[]){
	GString * string = foo[0];
	gchar * tag = foo[1];
	gchar * para_name = g_markup_escape_text(g_quark_to_string(key), -1);
	gchar * para_value = g_markup_escape_text(value, -1);
	g_string_append_printf(string, "<%s name=\"%s\">", tag, para_name);
	g_string_append_printf(string, "%s",  para_value);
	g_string_append_printf(string, "</%s>", tag);
	g_free(para_name);
	g_free(para_value);
}
gchar * ipc_command_to_string(IPCCommand * command){
	GString * string = g_string_new("");
	gchar * name = g_markup_escape_text(command->name, -1);
	gchar * cid = g_markup_escape_text(command->cid, -1);
	gpointer key, value;
	g_string_append_printf(string, "<command name=\"%s\" cid=\"%s\">", name, cid);
	g_free(name);
	g_free(cid);
	gpointer foo[] = {string, "p"};
	g_datalist_foreach(&command->parameters, _to_string_foreach, foo);
	gpointer bar[] = {string, "r"};
	g_datalist_foreach(&command->results, _to_string_foreach, bar);
	g_string_append_printf(string, "</command>");
	return g_string_free(string, FALSE);
}
gchar * ipc_command_list_to_string(GList * command_list){
	GList * node;
	GString * result = g_string_new("");
	for(node = command_list; node; node = node->next) {
		g_string_append(result, ipc_command_to_string(node->data));
		g_string_append_c(result, '\n');
	}
	return g_string_free(result, FALSE);
}
IPCCommand * ipc_command_new(gchar * cid, gchar * name) {
	IPCCommand * rt = g_slice_new0(IPCCommand);
	rt->cid = g_strdup(cid);
	rt->name = g_strdup(name);
	g_datalist_init(&rt->parameters);
	g_datalist_init(&rt->results);
	return rt;
}
void ipc_command_free(IPCCommand * command) {
	if(command->name) g_free(command->name);
	if(command->cid) g_free(command->cid);
	g_datalist_clear(&command->parameters);
	g_datalist_clear(&command->results);
	g_slice_free(IPCCommand, command);
}
void ipc_command_list_free(GList * list) {
	GList * node;
	for(node = list; node; node = node->next){
		ipc_command_free(node->data);
	}
	g_list_free(list);
}
void ipc_command_clear_parameters(IPCCommand * command) {
	g_datalist_clear(&command->parameters);
}
void ipc_command_clear_results(IPCCommand * command) {
	g_datalist_clear(&command->results);
}
void ipc_command_set_parameters_array(IPCCommand * command, gchar ** paras, gchar ** values) {
	gint i;
	for(i=0; paras[i]; i++){
		g_datalist_set_data_full(&command->parameters, paras[i], g_strdup(values[i]), g_free);
	}
}
void ipc_command_set_parameters_valist(IPCCommand * command, va_list va) {
	gchar * paraname;
	gchar * value;
	while(paraname = va_arg(va, gchar*)){
		value = va_arg(va, gchar *);
		g_datalist_set_data_full(&command->parameters, paraname, g_strdup(value), g_free);
	}
}
void ipc_command_set_results_valist(IPCCommand * command, va_list va) {
	gchar * paraname;
	gchar * value;
	while(paraname = va_arg(va, gchar*)){
		value = va_arg(va, gchar *);
		g_datalist_set_data_full(&command->results, paraname, g_strdup(value), g_free);
	}
}
void ipc_command_set_parameters(IPCCommand * command,  ...) {
	va_list va;
	va_start(va, command);
	ipc_command_set_parameters_valist(command, va);
	va_end(va);
}
void ipc_command_set_results(IPCCommand * command, ...) {
	va_list va;
	va_start(va, command);
	ipc_command_set_results_valist(command, va);
	va_end(va);
}
gchar * ipc_command_get_default_result(IPCCommand * command) {
	gchar * rt;
	rt = g_datalist_get_data(&command->results, "default");
	return rt;
}
