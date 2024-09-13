## Best Practices with Configuring LinkedIn Ads Conversion Fields Variable
The `linkedin_ads__conversion_fields` variable is designed for end users to properly measure the conversions at the proper level of granularity. By default, we use `external_website_conversions` and `one_click_leads` as they are arguably the most used conversion measures, and fulfill entirely separate objectives as conversions (Website Conversion and Lead Generation respectively). 

However, if you decide to configure your own conversion field variable fields, we highly recommend that you bring in conversions at the proper level of segmentation, so there aren't conversions that belong to multiple fields you bring in.

### Bad Practice Example

```yml
# dbt_project.yml
vars:
    linkedin_ads__conversion_fields: ['external_website_conversions', 'external_website_pre_click_conversions', 'external_website_post_click_conversions']
```

`external_website_conversions` is comprised of both `external_website_pre_click_conversions` and `external_website_post_click_conversions`, so `total_conversions` in the end models would be double counting conversions. 

### Good Practice Example

```yml
# dbt_project.yml
vars:
    linkedin_ads__conversion_fields: ['external_website_pre_click_conversions', 'external_website_post_click_conversions']
```

`external_website_pre_click_conversions` and `external_website_post_click_conversions` are two different type of external website conversions, so there should be no overlap. 

## Why don't metrics add up across different grains (Ex. ad level vs campaign level)?
Not all ads are served at the ad level. Some are delivered only at higher levels like the ad group or campaign. As a result, metrics like spend may differ across levels since not all ads are captured in ad-level reports.

To ensure data completeness, we separate reporting into hierarchical models (Ad, Ad Group, Campaign, etc.). Relying solely on ad-level reports could result in missing data from other levels.