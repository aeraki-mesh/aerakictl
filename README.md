# Aerakictl
A shell script for Istio and Aeraki debugging.

# Install

```bash
git clone https://github.com/aeraki-framework/aerakictl.git ~/aerakictl;source ~/aerakictl/aerakictl.sh
```

Note: please install the below dependencies:
* jq https://stedolan.github.io/jq/download/

# Command
## Aeraki Debugging
* aerakictl_aeraki_log   
## Istiod Debugging                                
* aerakictl_istiod_debug
* aerakictl_istiod_config                  
* aerakictl_istiod_registry                              
* aerakictl_istiod_endpoint                                             
* aerakictl_istiod_instances                     
* aerakictl_istiod_ads                   
* aerakictl_istiod_log
## Gateway Debugging
* aerakictl_gateway_config                                   
* aerakictl_gateway_log 
## Sidecar Debugging             
* aerakictl_sidecar_log                 
* aerakictl_sidecar_config               
* aerakictl_sidecar_stats
* aerakictl_sidecar_enable_debug
* aerakictl_sidecar_enable_trace
* aerakictl_sidecar_disable_debug
* aerakictl_sidecar_admin 
* aerakictl_app_log
