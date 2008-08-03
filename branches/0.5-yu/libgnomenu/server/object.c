#include <config.h>
#include <glib.h>
#include "object.h"

#if ENABLE_TRACING >= 1
#define LOG(fmt, args...) g_message("<GnomenuServer>::" fmt,  ## args)
#else
#define LOG(fmt, args...)
#endif

ObjectGroup * create_object_group(gchar * name) {
	ObjectGroup * group = g_slice_new0(ObjectGroup);
	group->name =g_strdup(name);
	group->object_hash = g_hash_table_new_full(g_str_hash, g_str_equal, NULL, NULL);
	return group;
}
void destroy_object_group(ObjectGroup * group) {
	g_hash_table_destroy(group->object_hash);
	g_free(group->name);
	g_slice_free(ObjectGroup, group);
}
static void object_unref(Object * object) {
	object->ref_count--;
	if(object->ref_count == 0) {
		GList * node;
		for(node = object->children; node; node = node->next)
			object_unref(node->data);
		g_list_free(object->children);
		g_datalist_clear(&object->properties);
		g_hash_table_remove(object->group->object_hash, object->name);
		g_free(object->name);
		g_slice_free(Object, object);
	}
}
gboolean create_object(ObjectGroup * group, gchar * name) {
	g_return_val_if_fail(name, FALSE);
	if(g_hash_table_lookup(group->object_hash, name)) return FALSE;
	Object * object = g_slice_new0(Object);
	object->name = g_strdup(name);
	object->group = group;
	object->ref_count = 1;
	object->children = NULL;
	g_datalist_init(&object->properties);
	g_hash_table_insert(group->object_hash, object->name, object);
	return TRUE;
}
gboolean destroy_object(ObjectGroup * group, gchar * name){
	g_return_val_if_fail(name, FALSE);
	Object * object = g_hash_table_lookup(group->object_hash, name);
	g_return_val_if_fail(object, FALSE);
	object_unref(object);
	return TRUE;
}
gboolean set_property(ObjectGroup * group, gchar * name, gchar * prop, gchar * value){
	g_return_val_if_fail(name, FALSE);
	g_return_val_if_fail(prop, FALSE);
	Object * object = g_hash_table_lookup(group->object_hash, name);
	g_return_val_if_fail(object, FALSE);
	if(value) {
		g_datalist_set_data_full(&object->properties, prop, g_strdup(value), g_free);
	} else {
		g_datalist_remove_data(&object->properties, prop);
	}
	return TRUE;
}
gboolean activate_object(ObjectGroup * group, gchar * name){
	return FALSE;
}
gboolean insert_child(ObjectGroup * group, gchar * name, gchar * child, gint pos) {
	g_return_val_if_fail(name, FALSE);
	g_return_val_if_fail(child, FALSE);
	Object * object = g_hash_table_lookup(group->object_hash, name);
	Object * obj_child = g_hash_table_lookup(group->object_hash, child);
	g_return_val_if_fail(object, FALSE);
	g_return_val_if_fail(child, FALSE);
	object->children = g_list_insert(object->children, obj_child, pos);
	obj_child->ref_count++;
	return TRUE;
}
gboolean remove_child(ObjectGroup * group, gchar * name, gchar * child) {
	g_return_val_if_fail(name, FALSE);
	g_return_val_if_fail(child, FALSE);
	Object * object = g_hash_table_lookup(group->object_hash, name);
	Object * obj_child = g_hash_table_lookup(group->object_hash, child);
	g_return_val_if_fail(object, FALSE);
	g_return_val_if_fail(child, FALSE);
	object->children = g_list_remove(object->children, obj_child);
	object_unref(obj_child);
	return TRUE;
}
static void prepend(GString * string, guint level){
	guint i;
	for(i=0; i<level; i++){
		g_string_append_c(string, ' ');
	}
}
static void introspect(GString * string, Object * object, guint level){
	prepend(string, level);
	g_string_append_printf(string, "<object name=\"%s\">\n", object->name);
	prepend(string, level + 1);
	g_string_append_printf(string, "<children>\n");
	GList * node;
	for(node = object->children; node; node = node->next){
		Object * child = node->data;
		introspect(string, child, level + 2);
	}
	prepend(string, level + 1);
	g_string_append_printf(string, "</children>\n");
TODO: // properties

	prepend(string, level);
	g_string_append_printf(string, "</object>\n");
}
gchar * introspect_object(ObjectGroup * group, gchar * name){
	g_return_val_if_fail(name, NULL);
	Object * object = g_hash_table_lookup(group->object_hash, name);
	g_return_val_if_fail(object, NULL);
	GString * string = g_string_new("");
	introspect(string, object, 0);
	return g_string_free(string, FALSE);
}
gboolean parse_objects(ObjectGroup * group, gchar * string){
	g_return_val_if_fail(string, FALSE);
	return FALSE;
}