package {{x.namespace_with_top_module}};

import bright.serialization.*;

{{
    name = x.name
    parent_def_type = x.parent_def_type
    export_fields = x.export_fields
    hierarchy_export_fields = x.hierarchy_export_fields
}}

{{~if x.comment != '' ~}}
/**
 * {{x.escape_comment}}
 */
{{~end~}}
public {{x.java_class_modifier}} class {{name}}{{if parent_def_type}} extends {{x.parent_def_type.full_name_with_top_module}}{{end}} {
    public {{name}}(ByteBuf _buf) { 
        {{~if parent_def_type~}}
        super(_buf);
        {{~end~}}
        {{~ for field in export_fields ~}}
        {{java_deserialize '_buf' field.convention_name field.ctype}}
        {{~if field.index_field~}}
        for({{java_box_define_type field.ctype.element_type}} _v : {{field.convention_name}}) {
            {{field.convention_name}}_Index.put(_v.{{field.index_field.convention_name}}, _v); 
        }
        {{~end~}}
        {{~end~}}
    }

    public {{name}}({{- for field in hierarchy_export_fields }}{{java_define_type field.ctype}} {{field.name}}{{if !for.last}},{{end}} {{end}}) {
        {{~if parent_def_type~}}
        super({{ for field in parent_def_type.hierarchy_export_fields }}{{field.name}}{{if !for.last}}, {{end}}{{end}});
        {{~end~}}
        {{~ for field in export_fields ~}}
        this.{{field.convention_name}} = {{field.name}};
        {{~if field.index_field~}}
        for({{java_box_define_type field.ctype.element_type}} _v : {{field.convention_name}}) {
            {{field.convention_name}}_Index.put(_v.{{field.index_field.convention_name}}, _v); 
        }
        {{~end~}}
        {{~end~}}
    }

    {{~if x.is_abstract_type~}}
    public static {{name}} deserialize{{name}}(ByteBuf _buf) {
        switch (_buf.readInt()) {
        {{~for child in x.hierarchy_not_abstract_children~}}
            case {{child.full_name_with_top_module}}.__ID__: return new {{child.full_name_with_top_module}}(_buf);
        {{~end~}}
            default: throw new SerializationException();
        }
    }
    {{~end~}}

    {{~ for field in export_fields ~}}
{{~if field.comment != '' ~}}
    /**
     * {{field.escape_comment}}
     */
{{~end~}}
    public final {{java_define_type field.ctype}} {{field.convention_name}};
    {{~if field.index_field~}} 
    public final java.util.HashMap<{{java_box_define_type field.index_field.ctype}}, {{java_box_define_type field.ctype.element_type}}> {{field.convention_name}}_Index = new java.util.HashMap<>();
    {{~end~}}
    {{~if field.gen_ref~}}
    public {{field.java_ref_validator_define}}
    {{~end~}}
    {{~end~}}

{{~if !x.is_abstract_type && x.parent_def_type~}}
    public static final int __ID__ = {{x.id}};

    @Override
    public int getTypeId() { return __ID__; }
{{~else if x.is_abstract_type && !x.parent_def_type~}}
    public abstract int getTypeId();
{{~end~}}

    {{~if parent_def_type~}}
    @Override
    {{~end~}}
    public void resolve(java.util.HashMap<String, Object> _tables) {
        {{~if parent_def_type~}}
        super.resolve(_tables);
        {{~end~}}
        {{~ for field in export_fields ~}}
        {{~if field.gen_ref~}}
        {{java_ref_validator_resolve field}}
        {{~else if field.has_recursive_ref~}}
        {{java_recursive_resolve field '_tables'}}
        {{~end~}}
        {{~end~}}
    }

    @Override
    public String toString() {
        return "{{full_name}}{ "
    {{~for field in hierarchy_export_fields ~}}
        + "{{field.convention_name}}:" + {{java_to_string field.convention_name field.ctype}} + ","
    {{~end~}}
        + "}";
    }
}
