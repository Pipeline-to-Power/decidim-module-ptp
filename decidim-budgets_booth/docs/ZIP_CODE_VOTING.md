# ZIP code voting

The zip-code voting feature provides a standardized format for creating scopes to represent ZIP code areas. In order to use the feature, the user must add the scopes, and scope types to the budgets in a specific order.

## Enabling ZIP code

Afteer adding this module, you should be able to enable/disable this feature from the admin pannel. To enable ZIP code workflow, you need to select the "scopes enabled" from your budget's component settings that you are aiming to enable. Also, you need to select the custom workflow "Vote based on ZIP code: allows participants to vote on budgets matching their entered ZIP code." that is designed for this feature.

## Adding Scope types

The user needs to create the following ZIP code types: "Area", "Area - Borough", "Area - Neighborhood", and "Area - Postal".

## Adding scopes

To create scopes, you need to follow the following procedure:

1. Create the parent scope which wraps up all other scopes. The parent scope should have the scope type of "Area" and the code equal to "Area".

| **name**         | **code**       | **scope_type** |
|    :---:         | :---:          |   :---:        |
| New York City    | AREA           | Area           |


2. Inside the parent scope (Area), create the boroughs that exist in the area. Each borough should have the scope type of "Area - Borough". For example, to create the Bronx sub-scope inside the parent scope, we will create the following scope:

| **name** | **code**    | **scope type**    |
| -------- | ----------- | ----------------- |
|  Bronx   | AREA_BRONX  | Area - Borough    |

3. Inside each borough, add all existing neighborhoods. Each neighborhood should have the scope type of "Area - Neighborhood". For example, to create the West Bronx sub-scope inside the Bronx scope, we will create the following scope:

| **name**      | **code**        | **scope type**         |
| --------      | --------------- | ---------------------- |
|  West Bronx   | AREA_BRONX_WEST | Area - Neighborhood    |

4. Finally, inside each neighborhood, add the ZIP codes that the particular area has. Each ZIP code should have the scope type of "Area - Postal". For example, to create the 10465 sub-scope inside the West Bronx scope, we will create the following scope:

| **name**      | **code**              | **scope type**   |
| --------      | --------------------- | ---------------- |
| 10465         | AREA_BRONX_WEST_10465 | Area - Postal    |

Note that each scope should have a unique code, which can be used to reference the scope in other parts of the system.

### Example Usage

Here is a visualization example of how to use the zip-code module to create scopes for New York City:

```yaml
- name: New York City
  code: AREA
  scope_type: Area
  - name: Bronx
    code: AREA_BRONX
    scope_type: Area - Borough
    - name: West Bronx
      code: AREA_BRONX_WEST
      scope_type: Area - Neighborhood
      - name: 10465
        code: AREA_BRONX_WEST_10465
        scope_type: Area - Postal
  ```

In the example above, we created a scope for New York City with the code AREA. Inside the AREA scope, we created a scope for the Bronx with the code AREA_BRONX. Inside the AREA_BRONX scope, we created a scope for the West Bronx with the code AREA_BRONX_WEST. Finally, inside the AREA_BRONX_WEST scope, we created a scope for the ZIP code 10465 with the code AREA_BRONX_WEST_10465.
