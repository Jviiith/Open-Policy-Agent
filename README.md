# Rego Overview (OPA)


## Generating a JSON Excution plan
Due to OPA working with JSON, there's a need to generate an execution plan from Terraform and put it into JSON format.

* To generate an execution plan (**bash**):
  - terraform plan -out="plan.tfplan"

* To convert plan/binary file into JSON (**bash**):
  - terraform show -json "plan.tfplan" > "plan.json"

## Rego Basics
When working in OPA, OPA builds a model/document which contains base document (static data loaded into OPA) & virtual document (data used containing rules for evaluation (aka Rego package)).

* To access & load data into OPA interactive shell/CLI/REPL (**bash**):
  - opa run 
  - opa run ./plan.json

* To view top level keys of the data document (**OPA/REPL**):
  - data[key] (*iterates over the entries in data*)
  > configuration key contains the configurations in JSON format.
  > variables key contains variable values used to generate the execution plan.
  > planned values key contains values that are being used to create the resources (essentially: configuration + variables keys)
  > resource_changes key contains the changes that will be made to the environment. Includes resources that will be created, updated, or destroyed.

* To access loaded data (**OPA/REPL**):
  - data (*view all data*)
  - data.planned_values (*view data inside planned_values*)
  - data.planned_values.root_module.resources (*view resources defined in configurations with all data/arguments filled out*)
  - data.planned_values.root_module.resources[keys] (*view contents/elements of the planned_values key*)
  - data.planned_values.root_module.resources[0] (*view a single resource*)

* To shorten a path (**OPA/REPL**):
  - import data.planned_values.root_module.resources (*last part becomes a placeholder for the path*)
  - import data.planned_values.root_module.resources[0] as elastic_ip_resource (*creates an alias for path*)
  - import future.keywords (*OPA package for intuitive syntax*)
  > Note: Import can be used to import interal OPA packages or external packages created

* To create a rule (**OPA/REPL**):
  - elastic_ip := data.planned_values.root_module.resources[0]
  - subnets[subnet]{
 subnet := data.planned_values.root_module.resources[_]
 subnet.type = "aws_subnet"
} (*a rule to select all resources of a certain type*)
  - unset subnets (*to remove a rule*)
  - 
  > Note: Import statements and rules are stored in a repl package (virtual document)
  > Note: There are 2 types of rules, paritial rules (rules that assaign a value to a variable) and complete rules (rules at have a condition and evaluate to True or False)

* To view data in resource_changes (**OPA/REPL**):
  - data.resource_changes[keys] (*iterates through the list of changed resources*)
  - data.resource_changes[0] (*view a single resource in list*)
  - subnets_created[subnet]{
    subnet := data.resource_changes[_]
    subnet.type = "aws_subnet"
    subnet.change.actions[_] = "create"
}   (*rule to view a list of created subnets*)

* To create a function (**OPA/REPL**):
  - get_resources_by_type(resources, type) = filtered_resources {
    filtered_resources := [resource | resource := resources[_]; resource.type = type]
}
  - subnets := get_resources_by_type(data.resource_changes, "aws_subnet")

Typically when using opa in CI/CD pipeline, we simply want to check and evaluate your resources based on a particular policy (see decison made by the policy).

* To execute policies in opa (**bash**):
  - opa exec --bundle ./policies/ --decision production/deny plan.json