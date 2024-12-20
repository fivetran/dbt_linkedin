# dbt_linkedin v0.10.0
[PR #38](https://github.com/fivetran/dbt_linkedin/pull/38) includes the following updates:

## Breaking Changes
- The `click_uri_type` field has been added to the below mentioned models. This field allows users to differentiate which click uri type (`text_ad` or `spotlight`) is being used to populate the results of the `click_uri` field. Please be aware this field only supports `text_ad` or `spotlight` click uri types. If you are interested in this package supporting more click uri ad types, please let us know in this [Feature Request](https://github.com/fivetran/dbt_linkedin_source/issues/70).
  - `stg_linkedin_ads__creative_history` (in the `dbt_linkedin_source` package)
  - `linkedin_ads__creative_report`
  - `linkedin_ads__url_report`

## Bug Fixes (upstream dbt_linkedin_source change)
- The `click_uri` field has been adjusted to populate the results following a coalesce on the `text_ad_landing_page`, `spotlight_landing_page`, or `click_uri` fields. For more details refer to [dbt_linkedin_source v0.10.0](https://github.com/fivetran/dbt_linkedin_source/releases/tag/v0.10.0) release notes.
  - This change is in response to a [LinkedIn Ads API](https://learn.microsoft.com/en-us/linkedin/marketing/community-management/contentapi-migration-guide?view=li-lms-2024-05#adcreativesv2-api-creatives-api) and [Fivetran LinkedIn Ads connector update](https://fivetran.com/docs/connectors/applications/linkedin-ads/changelog#january2024) which moved `click_uri` data to either the `text_ad_landing_page` or `spotlight_landing_page` fields depending on the creative type.

## Documentation Updates
- The `click_uri` field documentation has been updated to reflect the updated state of the field.
- Included a new `DECISIONLOG.md` entry to highlight why it's possible metrics don't add up across different grains.

## Under the Hood
- Updates to the `linkedin_creative_history_data` seed file to include the following new fields to ensure accurate data validation tests:
  - `text_ad_landing_page`
  - `spotlight_landing_page`
  
# dbt_linkedin v0.9.1
[PR #41](https://github.com/fivetran/dbt_linkedin/pull/41) includes the following updates:

## Bug Fix
- Ensures that the recent addition of conversions (see v0.9.0 below) is indeed backwards compatible with users already including `conversion_value_by_local_currency` as a passthrough column.

## Under the Hood
- Updates the consistency data validation tests (maintainers only) to more accurately test the grain of each report.

# dbt_linkedin v0.9.0
[PR #36](https://github.com/fivetran/dbt_linkedin/pull/36) includes the following updates:

## Feature Updates: Conversion Support!
We have added more robust support for conversions in our data models by doing the following: 
- Adds a `conversion_value_by_local_currency` field to each `_report` end model, representing the value of conversions that occurred on each day for each campaign/campaign_group/creative/url/account.
- Created a `linkedin_ads__conversion_fields` variable to pass through and transform additional conversion value metrics into their aggregate sums.
  - Set current variable defaults in the `dbt_project.yml` to bring in the most used conversion fields `external_website_conversions` and `one_click_leads` by default.
  - Instructions on how to set your own fields [are available in the README](https://github.com/fivetran/dbt_linkedin/blob/main/README.md#adding-in-conversion-fields-variable).
- Adds a `total_conversions` metric in our end models to track all conversions being brought in by the `linkedin_ads_conversion_fields` variable.
> The above new field additions are 🚨 **breaking changes** 🚨.

## Documentation Update 
- Documents how to set your own passthrough fields with the variable `linkedin_ads__conversion_fields` [in the README](https://github.com/fivetran/dbt_linkedin_source/blob/main/README.md#adding-in-conversion-fields-variable).
- [Created a DECISIONLOG](https://github.com/fivetran/dbt_linkedin/blob/main/DECISIONLOG.md#best-practices-with-configuring-linkedin-ads-conversion-fields-variable) to describe best practices in configuring the `linkedin_ads__conversion_fields` variable. 

## Under the Hood
- Added a new [version](https://github.com/fivetran/dbt_linkedin_ads/blob/main/macros/linkedin_ads_persist_pass_through_columns.sql) of the `persist_pass_through_columns()` [macro](https://github.com/fivetran/dbt_fivetran_utils/blob/v0.4.10/macros/persist_pass_through_columns.sql) in which we can include `coalesces` and properly check between conversion field values and the existing passthrough column.
- Updated the PR templates to align with our most up-to-date standards.
- Included auto-releaser GitHub Actions workflow to automate future releases.
- Addition of integrity and consistency validation tests within `integration_tests` for the Linkedin transformation models.
- Updated `linkedin_ad_analytics_by_creative_data` seed file with relevant conversion fields for more robust testing. 

## Contributors
- [Seer Interactive](https://www.seerinteractive.com/?utm_campaign=Fivetran%20%7C%20Models&utm_source=Fivetran&utm_medium=Fivetran%20Documentation)


# dbt_linkedin v0.8.0
[PR #32](https://github.com/fivetran/dbt_linkedin/pull/32) includes the following updates:

## Breaking changes
- Updated materializations of [dbt_linkedin_source](https://github.com/fivetran/dbt_linkedin_source/blob/main/CHANGELOG.md) non-`tmp` staging models from views to tables. This is to bring the materializations into alignment with other ad reporting packages and eliminate errors in Redshift.
- Updated the name of the source created by `dbt_linkedin_source` from `linkedin` to `linkedin_ads`. This was to bring the naming used in this package in alignment with our other ad packages and for compatibility with the union schema feature.
  - ❗ If you are using this source, you will need to update the name.
- Updated the following identifiers for consistency with the source name and compatibility with the union schema feature:

| current  | previous |
|----------|----------|
| linkedin_ads_account_history_identifier | linkedin_account_history_identifier
| linkedin_ads_ad_analytics_by_creative_identifier | linkedin_ad_analytics_by_creative_identifier
| linkedin_ads_campaign_group_history_identifier | linkedin_campaign_group_history_identifier
| linkedin_ads_campaign_history_identifier | linkedin_campaign_history_identifier
| linkedin_ads_creative_history_identifier | linkedin_creative_history_identifier
| linkedin_ads_ad_analytics_by_campaign_identifier | linkedin_ad_analytics_by_campaign_identifier

- If you are using the previous identifier, be sure to update to the current version!

## Feature update 🎉
- Unioning capability! This adds the ability to union source data from multiple linkedin connectors. Refer to the [Union Multiple Connectors README section](https://github.com/fivetran/dbt_linkedin/blob/main/README.md#union-multiple-connectors) for more details.

## Under the hood 🚘
- In the source package, updated tmp models to union source data using the `fivetran_utils.union_data` macro. 
- To distinguish which source each field comes from, added `source_relation` column in each staging and downstream model and applied the `fivetran_utils.source_relation` macro.
  - The `source_relation` column is included in all joins in the transform package. 
- Updated tests to account for the new `source_relation` column.

[PR #29](https://github.com/fivetran/dbt_linkedin/pull/329) includes the following updates:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job.
- Updated the pull request [templates](/.github).

# dbt_linkedin v0.7.0
## 🚨 Breaking Changes 🚨
Due to Linkedin Ads API [change in January 2023](https://learn.microsoft.com/en-us/linkedin/marketing/integrations/recent-changes?view=li-lms-2022-12#january-2023), there have been updates in the Linkedin Ads Fivetran Connector and therefore, updates to this Linkedin package. 

The following fields have been completely deprecated in the `stg_linkedin_ads__creative_history` model ([dbt_linkedin_source PR #48](https://github.com/fivetran/dbt_linkedin_source/pull/48)) and therefore removed from the below respective models in this package([#28](https://github.com/fivetran/dbt_linkedin/pull/28)):
- `type` (removed from `*_creative_report`)
- `call_to_action_label_type` (removed from `*_creative_report`)
- `version_tag` (removed from `*_creative_report` and `*_url_report`)

## Updates
[PR #28](https://github.com/fivetran/dbt_linkedin/pull/28) introduces the below changes:
- `linkedin_ads__creative_report` now leverages `report.creative_id` instead of `creative.creative_id`. 
- `linkedin_ads__campaign_report` now leverages `report.campaign_id` instead of `campaign.campaign_id`.
- `linkedin_ads__url_report` now leverages `report.creative_id` instead of `creative.creative_id`.

## Under the hood
- `integration_tests/seed/linkedin_creative_history_data` has been updated to reflect new fields and deprecated field updates
- Legacy fields have been updated respectively in the connector and `dbt_linkedin_source v0.7.0` includes modifications that could affect the below fields within the `linkedin_ads__creative_history` model:
  - `last_modified_at`
  - `created_at`
  - `status`
  
For more information, please refer to [dbt_linkedin_source PR #48](https://github.com/fivetran/dbt_linkedin_source/pull/48).
# dbt_linkedin v0.6.1

## Bugfixes
- `linkedin_ads__url_report` will now effectively filter out all those entries from `stg_linkedin_ads__creative_history` that are not the latest version of the creative. ([PR #26](https://github.com/fivetran/dbt_linkedin/pull/26))

## Contributors
- [@aleix-cd](https://github.com/aleix-cd) ([PR #26](https://github.com/fivetran/dbt_linkedin/pull/26))

# dbt_linkedin v0.6.0

## 🚨 Breaking Changes 🚨:
[PR #22](https://github.com/fivetran/dbt_linkedin/pull/22) includes the following breaking changes:
- Dispatch update for dbt-utils to dbt-core cross-db macros migration. Specifically `{{ dbt_utils.<macro> }}` have been updated to `{{ dbt.<macro> }}` for the below macros:
    - `any_value`
    - `bool_or`
    - `cast_bool_to_text`
    - `concat`
    - `date_trunc`
    - `dateadd`
    - `datediff`
    - `escape_single_quotes`
    - `except`
    - `hash`
    - `intersect`
    - `last_day`
    - `length`
    - `listagg`
    - `position`
    - `replace`
    - `right`
    - `safe_cast`
    - `split_part`
    - `string_literal`
    - `type_bigint`
    - `type_float`
    - `type_int`
    - `type_numeric`
    - `type_string`
    - `type_timestamp`
    - `array_append`
    - `array_concat`
    - `array_construct`
- For `current_timestamp` and `current_timestamp_in_utc` macros, the dispatch AND the macro names have been updated to the below, respectively:
    - `dbt.current_timestamp_backcompat`
    - `dbt.current_timestamp_in_utc_backcompat`
- `packages.yml` has been updated to reflect new default `fivetran/fivetran_utils` version, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

## 🎉 Features 🎉
- For use in the [dbt_ad_reporting package](https://github.com/fivetran/dbt_ad_reporting), users can now allow records having nulls in url fields to be included in the `ad_reporting__url_report` model. See the [dbt_ad_reporting README](https://github.com/fivetran/dbt_ad_reporting) for more details ([#24](https://github.com/fivetran/dbt_linkedin/pull/24)). 
## 🚘 Under the Hood 🚘
- Disabled the `not_null` test for `linkedin_ads__url_report` when null urls are allowed ([#24](https://github.com/fivetran/dbt_linkedin/pull/24)).

# dbt_linkedin v0.5.0

PR [#21](https://github.com/fivetran/dbt_linkedin/pull/21) includes the following changes:

## 🚨 Breaking Changes 🚨
- **ALL** models and **ALL** variables now have the prefix `linkedin_ads_*`. They previously were prepended with `linkedin_*`. This includes the required schema and database variables. We made this change to better discern between Linkedin Ads and [Linkedin Pages](https://github.com/fivetran/dbt_linkedin_pages/tree/main).
- The following models have been renamed:
  - `linkedin__account_ad_report` -> `linkedin_ads__account_report`
  - `linkedin__campaign_ad_report` -> `linkedin_ads__campaign_report`
  - `linkedin__campaign_group_ad_report` -> `linkedin_ads__campaign_group_report`
- The `linkedin__ad_adapter` model has been renamed and refactored into two separate models:
  - `linkedin_ads__url_report`: Each record in this table represents the daily performance at the url level.
  - `linkedin_ads__creative_report`: Each record in this table represents the daily performance at the creative level.
- The declaration of passthrough variables within your root `dbt_project.yml` has changed. To allow for more flexibility and better tracking of passthrough columns, you will now want to define passthrough columns in the following format:
```yml
vars:
  linkedin_ads__campaign_passthrough_metrics: # this will pass through fields to the account, campaign, and campaign group report models. it pulls from `ad_analytics_by_campaign`
    - name: "my_field_to_include" # Required: Name of the field within the source.
      alias: "field_alias" # Optional: If you wish to alias the field within the staging model.
  linkedin_ads__creative_passthrough_metrics: # this will pass through fields to the creative and url report models.  it pulls from `ad_analytics_by_creative`
    - name: "my_field_to_include"
      alias: "field_alias"
```
- Staging models are now by default written within a schema titled (`<target_schema>` + `_linkedin_ads_source`) in your destination. Previously, this was titled (`<target_schema>` + `_stg_linkedin`).

## 🎉 Feature Enhancements 🎉
- README updates for easier navigation and use of the package.
- Addition of identifier variables for each of the source tables to allow for further flexibility in source table direction within the dbt project.
- Addition of new columns to `_report` models.
- More complete table and column documentation.
- More robust schema tests.

# dbt_linkedin v0.4.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_linkedin_source`. Additionally, the latest `dbt_linkedin_source` package has a dependency on the latest `dbt_fivetran_utils`. Further, the latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

# dbt_linkedin v0.1.0 -> v0.3.0
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
