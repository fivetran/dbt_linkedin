# LinkedIn Ads 

This package models LinkedIn Ads data from [Fivetran's connector](https://fivetran.com/docs/applications/linkedin-ads). It uses data in the format described by [this ERD](https://docs.google.com/presentation/d/1nwR5efra1p3S1uOwUgU9Wdx7WBKXE7onxNDffK0IpgM/edit#slide=id.g311502b468_5_443).

The main focus of the package is to transform the core ad object tables into analytics-ready models, including an 'ad adapter' model that can be easily unioned in to other ad platform packages to get a single view. 

## Models

This package contains transformation models, designed to work simultaneously with our [LinkedIn Ads source package](https://github.com/fivetran/dbt_linkedin_source). A dependency on the source package is declared in this package's `packages.yml` file, so it will automatically download when you run `dbt deps`. The primary outputs of this package are described below.

| **model**                          | **description**                                                                                                        |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| linkedin__ad_adapter               | Each record represents the daily ad performance of each creative, including information about the used UTM parameters. |
| linkedin__account_ad_report        | Each record represents the daily ad performance of each account.                                                       |
| linkedin__campaign_ad_report       | Each record represents the daily ad performance of each campaign.                                                      |
| linkedin__campaign_group_ad_report | Each record represents the daily ad performance of each campaign group.                                                |

## Installation Instructions
Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

## Configuration
By default, this package will look for your LinkedIn Ads data in the `linkedin_ads` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). If this is not where your LinkedIn Ads data is, please add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
config-version: 2

vars:
    linkedin_schema: your_database_name
    linkedin_database: your_schema_name 
```

For additional configurations for the source models, please visit the [Linkedin source package](https://github.com/fivetran/dbt_linkedin_source).

## Contributions

Additional contributions to this package are very welcome! Please create issues
or open PRs against `master`. Check out 
[this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) 
on the best workflow for contributing to a package.

## Resources:
- Learn more about Fivetran [here](https://fivetran.com/docs)
- Check out [Fivetran's blog](https://fivetran.com/blog)
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
