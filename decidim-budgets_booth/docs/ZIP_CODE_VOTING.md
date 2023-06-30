# ZIP code voting

The ZIP code voting feature provides a custom workflow for budgeting for creating scopes to represent ZIP code areas. In order to use the feature, the administrator must add the proper scopes and scope types, and configure the budgets component to use these scopes.

## Enabling ZIP code voting

After installing this module, you should be able to enable/disable this feature from the admin panel. To enable ZIP code workflow, you need to select the "scopes enabled" from your budget's component settings for which you want to enable this feature. Also, you need to select the custom workflow "Vote based on ZIP code: allows participants to vote on budgets matching their entered ZIP code." that is designed for this feature.

## Adding scope types

The administrator needs to create the following scope types:

- Area
- Area - Borough
- Area - Neighborhood
- Area - Postal

## Adding scopes

To create scopes, you need to follow the following procedure:

1. Create the parent scope which wraps up all other scopes. The parent scope should have the scope type of "Area" and the code equal to "Area".

| **name**         | **code**       | **scope_type** |
|    :---:         | :---:          |   :---:        |
| New York City    | NY             | Area           |


2. Inside the parent scope (Area), create the boroughs that exist in the area. Each borough should have the scope type of "Area - Borough". For example, to create the Bronx sub-scope inside the parent scope, we will create the following scope:

| **name** | **code**    | **scope type**    |
| -------- | ----------- | ----------------- |
|  Bronx   | NY_BRONX    | Area - Borough    |

3. Inside each borough, add all existing neighborhoods. Each neighborhood should have the scope type of "Area - Neighborhood". For example, to create the West Bronx sub-scope inside the Bronx scope, we will create the following scope:

| **name**      | **code**        | **scope type**         |
| --------      | --------------- | ---------------------- |
|  West Bronx   | NY_BRONX_WEST   | Area - Neighborhood    |

4. Finally, inside each neighborhood, add the ZIP codes that the particular area has. Each ZIP code should have the scope type of "Area - Postal". For example, to create the 10465 sub-scope inside the West Bronx scope, we will create the following scope:

| **name**      | **code**              | **scope type**   |
| --------      | --------------------- | ---------------- |
| 10465         | NY_BRONX_WEST_10465   | Area - Postal    |

Note that each scope should have a unique code, which can be used to reference the scope in other parts of the system. If you need to duplicate the same ZIP code under multiple neighborhoods, you can do that by using unique code for each of ZIP codes within the neighborhoods.

Note that the ZIP codes need to be always defined at the deepest level of this structure. With the example structure you cannot, for example, add ZIP codes directly under the boroughs because you have one more hierarchy level of under that. Maximum depth for the scopes is three as in the example given above (Borough -> Neighborhood -> Postal) but you may also define less levels as long as the ZIP codes are always found at the deepest level within the hierarchy.

If you need to add ZIP codes that do not belong to any neighborhood in the given example, you can create a neighborhood named "!General" where you add such ZIP codes. This needs to be done in order to maintain the correct levels in the hierarchy. The logic is expecting to find the ZIP codes always at the deepest level, so if you would add them directly under the boroughs, they would not be considered ZIP codes.

### Example usage

Here is a visualization example of how to use the zip-code module to create scopes for New York City:

```yaml
- name: New York City
  code: NY
  scope_type: Area
  - name: Bronx
    code: NY_BRONX
    scope_type: Area - Borough
    - name: West Bronx
      code: NY_BRONX_WEST
      scope_type: Area - Neighborhood
      - name: 10465
        code: NY_BRONX_WEST_10465
        scope_type: Area - Postal
  ```

In the example above, we created a scope for New York City with the code NY. Inside the NY scope, we created a scope for the Bronx borough with the code NY_BRONX. Inside the NY_BRONX scope, we created a scope for the West Bronx neighborhood with the code NY_BRONX_WEST. Finally, inside the NY_BRONX_WEST scope, we created a scope for the ZIP code 10465 with the code NY_BRONX_WEST_10465.
