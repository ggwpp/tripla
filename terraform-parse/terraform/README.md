1. Make it work first
- To support multiple environments deployment this should turn into the module thus provider should not be stored in the module. This cause the chicken-eegs problem when destory the resource.
- Remove non-exist variable
- Create EKS managed node group

2. Optimize
    2.1 To support multiple environments deployment this should turn into the module thus provider should not be stored in the module. This cause the chicken-eegs problem when destory the resource.
    2.2 Make variable configurable
    2.3 consitency tagging


### Test
1. Update the desired configuration at `test/eks.tf`
2. terraform plan
