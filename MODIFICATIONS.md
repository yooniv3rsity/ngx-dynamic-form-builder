# Custom Modifications

* 2022-01-25 - implemented metadata depth limit to fix recursion error (e.g. user->company->user)
* 2022-01-25 - implemented allowedNestedModels to explicitly specify which sub-models are allowed to be created.
* 2022-01-25 - fix jest setup - updated config to use es2015, use getGlobal() instead of window to fix error in jest env
* 2022-02-08 - update package details and release 2.1.0
* 2022-02-10 - ---- merge master (fixes #192/#194, setObject works correctly with deeply nested FormArrays)
* 2022-02-10 - released as 2.2.0
* 2022-04-21 - bugfix: filter deleted entries from metadata properties array, was erroring because metadata depth limit left explicit "undefined" entries, released as 2.2.0rc3
* 2022-04-21 - released as 2.2.0rc5
* 2022-09-07 - ---- merge master 2.2.2 (fix inconsistent behavior of setObject, lock dependency versions)
* 2022-09-07 - refactor lib.ts changes, add comments and try to make more transparent what has been changed.
* 2022-09-15 - migrate to angular 14 (for correct peer deps), document & fix testing setup
* 2022-09-15 - released as 2.3.0rc1
* 2022-09-26 - 2.3.0rc2 - update dependencies + peerDependency info / class-transformer-global-storage -> @yoolabs/class-transformer@^0.5.1
* 2022-09-26 - 2.3.0rc3 - fix peerDependency info (class transformer 0.5.x)
* 2022-09-26 - 2.3.0rc4 - class-validator-multi-lang -> class-validator@^0.13.2
* 2023-01-17 - 2.3.3 - buggy release, tried to merge in master of base repo. (Unpublished again)
* 2023-01-18 - custom migration to ng15. Note install needs to be executed with --force due to flex-layout@14
* 2023-01-18 - update code to work with new class-transformer ("instance" instead of "class")

## Testing

`npm run test` is the all-in-one Cypress command. It executes

* `lib:build` -- build dist lib
* `test:integrations-prepare` -- installs test env at integrations/app and installs local dist lib
* `test:integrations-serve` -- setup testing server
*  `cy:run` -- init cypress

To execute custom unit tests, use `npm run jest`.

## Create custom release

* Run tests manually as needed
* libs/ngx-dynamic-form-builder has its own package.json! Update version accordingly!
* `npm run lib:build-lib` to populate dist folder
* validate generated package
* `npm run publish`


## Nested Forms and Models

### Depth limiting

By default, ngx-dynamic-form-builder will create all Submodels that it can find in specified model, with a max depth of 2.

```ts
class Company {
	@Expose()
	@Type(()=>User)
	manager?:any;
}

class User {
	@Expose()
	name?: string;

	@Type(type => Company)
	@Expose()
	company?: Company;
}

const form = new DynamicFormBuilder().rootFormGroup(User,{})

/*
  form.value will look like:
  { 
    name: '', 
    company: { <-- sub model level 1
      manager: { <-- sub model level 2
        name: ''
        --> no sub model level 3
      }
    }
  }
*/

```

You can change the depth by specifying a different value for maxNestedModelDepth:

```ts
const form = new DynamicFormBuilder().rootFormGroup(User,{}, {maxNestedModelDepth:0})

/*
  form.value will look like:
  { 
    name: '', 
    --> no sub models at all
  }
*/
```

### Create only specific submodels

Sometimes the form model may contain @Type decorated props, but you don't want these submodels to appear in the form.

Use _allowedNestedModels_ to specify a list of props / dot-separated prop paths that you want to be created.

All other submodels will be excluded.

```ts

/* Company + User from above example */

class Package {
	@Type(type => User)
	@Expose()
	user?: User;

	@Type(type => Company)
	@Expose()
	company?: Company;
}

const form = new DynamicFormBuilder().rootFormGroup(Package,{}, {allowedNestedModels:[]})

/*
  form.value will look like:
  { 
    --> no sub models at all
  }
*/

const form = new DynamicFormBuilder().rootFormGroup(Package,{}, {allowedNestedModels:['user','company']})

/*
  form.value will look like:
  { 
    user:{ name : '' },
    company:{ },
  }
*/

const form = new DynamicFormBuilder().rootFormGroup(Package,{}, {allowedNestedModels:['user','company','company.manager']})

/*
  form.value will look like:
  { 
    user: { name : '' },
    company:{ 
      manager: { name : '' }
	},
  }
*/
```

