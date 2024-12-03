{# Adapted from fivetran_utils.persist_pass_through_columns() macro to include coalesces #}

{% macro linkedin_ads_persist_pass_through_columns(pass_through_variable, identifier=none, transform='', coalesce_with=none, except_variable=none, exclude_fields=[]) %}

{% set except_fields = [] %}
{% if except_variable is not none %}
    {# Start creating list of fields to exclude #}
    {% for item in var(except_variable) %}
        {% do except_fields.append(item.name) %}
    {% endfor %}
{% endif %}

{% for field in exclude_fields %}
    {% do except_fields.append(field) %}
{% endfor %}

{% if var(pass_through_variable, none) %}
    {% for field in var(pass_through_variable) %}
    {% set field_name = field.alias|default(field.name)|lower if field is mapping else field|lower %}
    
        {% if field_name not in except_fields %}
        , {{ transform ~ '(' ~ ('coalesce(' if coalesce_with is not none else '') ~ (identifier ~ '.' if identifier else '') ~ field_name ~ ((', ' ~ coalesce_with ~ ')') if coalesce_with is not none else '') ~ ')' }} as {{ field_name }}
        {% endif %}

    {% endfor %}
{% endif %}

{% endmacro %}