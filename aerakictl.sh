#!/usr/local/bin/bash

alias k=kubectl

aerakictl_get_pod()
{ 
  if [ $# -eq 0 ]
  then
    echo "Please specify app and namespace in the parameters, like \"aerakictl_get_pod productpage default\" , if namespace is default, the second parameter can leave unspecied."
    return 1
  elif [ $# -eq 1 ] || [ -z "$2" ]
  then
    ns="default"
  else
    ns=$2
  fi

  pod=`k get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -n $ns|grep $1|head -n 1|head -n 1`
  if [ -z "$pod" ]
  then
    echo "Can't find pod "$1" in namespace "$2
    return 1
  else
    echo $pod
  fi
}

aerakictl_istiod_log()
{
  pod=`aerakictl_get_pod istiod istio-system`
  if [ $? -ne 0 ]
  then
    echo $pod
    return 1
  else
    k logs $@ $pod -n istio-system 
  fi
}

aerakictl_istiod_log_dump()
{
  aerakictl_istiod_log > istiodlog_`date +%F%H%M%S`
}

aerakictl_istiod_debug()
{
  pod=`aerakictl_get_pod istiod istio-system`
  if [ $# -eq 0 ]
  then
    echo "Please specify the resource in the input parameter, you can choose one from the following output"
    k exec $pod -n istio-system -- curl http://127.0.0.1:15014/debug
  else
      k exec $pod -n istio-system -- curl http://127.0.0.1:15014/debug/$@
  fi
}

aerakictl_istiod_config()
{
  pod=`aerakictl_get_pod istiod istio-system`
  if [ $? -ne 0 ]
  then
    echo $pod
    return 1
  else
    k exec $pod -n istio-system -- curl http://127.0.0.1:15014/debug/configz
  fi
}

aerakictl_istiod_registry()
{
  pod=`aerakictl_get_pod istiod istio-system`
  if [ $? -ne 0 ]
  then
    echo $pod
    return 1
  else
    k exec $pod -n istio-system -- curl http://127.0.0.1:15014/debug/registryz
  fi
}

aerakictl_istiod_ads()
{
  pod=`aerakictl_get_pod istiod istio-system`
  if [ $? -ne 0 ]
  then
    echo $pod
    return 1
  else
    k exec $pod -n istio-system -- curl http://127.0.0.1:15014/debug/adsz
  fi
}

aerakictl_istiod_endpoint()
{
  pod=`aerakictl_get_pod istiod istio-system`
  if [ $? -ne 0 ]
  then
    echo $pod
    return 1
  else
    k exec $pod -n istio-system -- curl http://127.0.0.1:15014/debug/endpointz
  fi
}

aerakictl_istiod_instances()
{
  pod=`aerakictl_get_pod istiod istio-system`
  if [ $? -ne 0 ]
  then
    echo $pod
    return 1
  else
    k exec $pod -n istio-system -- curl http://127.0.0.1:15014/debug/instancesz
  fi
}

aerakictl_sidecar_config()
{
  if [ $# -eq 0 ]
  then
    echo "Please specify app and namespace in the parameters, like \"aerakictl_sidecar_config productpage default\" , if namespace is default, the second parameter can leave unspecied."
  else
    pod=`aerakictl_get_pod $1 $2`
    if [ $? -ne 0 ]
    then
      echo $pod
      return 1
    else
      if [ $# -eq 1 ]
      then
        k exec $pod -c istio-proxy -- curl "127.0.0.1:15000/config_dump?include_eds"
      else
        k exec $pod -c istio-proxy -n $2 -- curl "127.0.0.1:15000/config_dump?include_eds"
      fi
    fi
  fi
}

aerakictl_sidecar_enable_trace()
{
  if [ $# -eq 0 ]
  then
    echo "Please specify app and namespace in the parameters, like \"aerakictl_sidecar_enable_trace productpage default\" , if namespace is default, the second parameter can leave unspecied."
  else
    pod=`aerakictl_get_pod $1 $2`
    if [ $? -ne 0 ]
    then
      echo $pod
      return 1
    else
      if [ $# -eq 1 ]
      then
        k exec $pod -c istio-proxy -- curl -d"dummy" 127.0.0.1:15000/logging\?level=trace
      else
        k exec $pod -c istio-proxy -n $2 -- curl -d"dummy" 127.0.0.1:15000/logging\?level=trace
      fi
    fi
  fi
}

aerakictl_sidecar_enable_debug()
{
  if [ $# -eq 0 ]
  then
    echo "Please specify app and namespace in the parameters, like \"aerakictl_sidecar_enable_debug productpage default\" , if namespace is default, the second parameter can leave unspecied."
  else
    pod=`aerakictl_get_pod $1 $2`
    if [ $? -ne 0 ]
    then
      echo $pod
      return 1
    else
      if [ $# -eq 1 ]
      then
        k exec $pod -c istio-proxy -- curl -d"dummy" 127.0.0.1:15000/logging\?level=debug
      else
        k exec $pod -c istio-proxy -n $2 -- curl -d"dummy" 127.0.0.1:15000/logging\?level=debug
      fi
    fi
  fi
}

aerakictl_sidecar_disable_debug()
{
  if [ $# -eq 0 ]
  then
    echo "Please specify app and namespace in the parameters, like \"aerakictl_sidecar_disable_debug productpage default\" , if namespace is default, the second parameter can leave unspecied."
  else
    pod=`aerakictl_get_pod $1 $2`
    if [ $? -ne 0 ]
    then
      echo $pod
      return 1
    else
      if [ $# -eq 1 ]
      then
        k exec $pod -c istio-proxy -- curl -d"dummy" 127.0.0.1:15000/logging\?level=info
      else
        k exec $pod -c istio-proxy -n $2 -- curl -d"dummy" 127.0.0.1:15000/logging\?level=info
      fi
    fi
  fi
}

aerakictl_sidecar_admin()
{
  if [ $# -lt 3 ]
  then
    echo "Please specify the pod, namespace and resource in the input parameter, you can choose one from the following output"
    k exec `aerakictl_get_pod $1 $2` -c istio-proxy -n $2 -- curl 127.0.0.1:15000/dummy
  else
    pod=`aerakictl_get_pod $1 $2`
    if [ $? -ne 0 ]
    then
      echo $pod
      return 1
    else
        k exec $pod -c istio-proxy -n $2 -- curl 127.0.0.1:15000/$3
    fi
  fi
}

aerakictl_sidecar_stats()
{
  aerakictl_sidecar_admin consumer metaprotocol /stats/prometheus
}

aerakictl_sidecar_log()
{
  if [ $# -eq 0 ]
  then
    echo "Please specify app and namespace in the parameters, like \"aerakictl_sidecar_log productpage default\" , if namespace is default, the second parameter can leave unspecied."
  else
    pod=`aerakictl_get_pod $1 $2`
    if [ $? -ne 0 ]
    then
      echo $pod
      return 1
    else
      if [ $# -eq 1 ]
      then
        k logs $pod -c istio-proxy 
      else
        index=1
        kubectlparameter=()
        for arg in $*                                          
        do
          if [ $index -gt 2 ]
          then
            kubectlparameter+=$arg
          fi
          let index+=1
        done
        k logs $kubectlparameter $pod -c istio-proxy -n $2
      fi
    fi
  fi
}

aerakictl_get_container()
{
  if [ $# -eq 0 ]
  then
    echo "Please specify app and namespace in the parameters, like \"aerakictl_get_pod productpage default\" , if namespace is default, the second parameter can leave unspecied."
    return 1
  elif [ $# -eq 1 ] || [ -z "$2" ]
  then
    container=`k get pods --template '{{range .items}}{{range .spec.containers}}{{.name}}{{"\n"}}{{end}}{{end}}' |grep $1|head -n 1`
  else
    container=`k get pods --template '{{range .items}}{{range .spec.containers}}{{.name}}{{"\n"}}{{end}}{{end}}' -n $2|grep $1|head -n 1`
  fi

  if [ -z "$container" ]
  then
    echo "Can't find container "$1" in namespace "$2
    return 1
  else
    echo $container
  fi
}

aerakictl_app_log()
{ 
  setopt local_options BASH_REMATCH
  if [ $# -eq 0 ]
  then
    echo "Please specify app and namespace in the parameters, like \"aerakictl_app_log productpage default\" , if namespace is default, the second parameter can leave unspecied."
  else
    pod=`aerakictl_get_pod $1 $2`
    if [ $? -ne 0 ]
    then
      echo $pod
      return 1
    else 
      if [ $# -eq 1 ]
      then
        k logs $pod -c $1
      else
        index=1
        kubectlparameter=()
        for arg in $*
        do
          if [ $index -gt 2 ]
          then
            kubectlparameter+=$arg
          fi
          let index+=1
        done
        container=$pod
        if [[ $container =~ (.*)-[0-9,a-z]+-[0-9,a-z]{5}$ ]]
        then
          container=${BASH_REMATCH[2]}
        elif [[ $container =~ .*-([0-9,a-z]+)-[0-9]+$ ]]
        then 
          container=${BASH_REMATCH[2]}
        else
          container=$1
        fi  
        container=`aerakictl_get_container $1 $2`
        k logs $kubectlparameter $pod -c $container -n $2
      fi
    fi
  fi
}

aerakictl_gateway_config()
{
  pod=`aerakictl_get_pod istio-ingressgateway istio-system`
  if [ $? -ne 0 ]
  then
    echo $pod
    return 1
  else
    k exec $pod -c istio-proxy -n istio-system -- curl 127.0.0.1:15000/config_dump
  fi
}

aerakictl_gateway_log()
{
  pod=`aerakictl_get_pod istio-ingressgateway istio-system`
  if [ $? -ne 0 ]
  then
    echo $pod
    return 1
  else
    k logs $pod -c istio-proxy -n istio-system
  fi
}

aerakictl_mesh_operator_log()
{
  if [ $# -eq 0 ]
  then
    echo "Please specify namespace in the parameters."
  else
    pod=`aerakictl_get_pod mesh-kube-operator  $1`
    if [ $? -ne 0 ]
    then
      echo $pod
      return 1
    else
      k logs -n $@ $pod
    fi
  fi
}

aerakictl_dangerous_delete_istiod_pod()
{
  pod=`aerakictl_get_pod istiod istio-system`
  if [ $? -ne 0 ]
  then
    echo $pod
    return 1
  else
    k delete pod $pod -n istio-system
  fi
}

aerakictl_dangerous_delete_aeraki_pod()
{
  pod=`aerakictl_get_pod aeraki istio-system`
  if [ $? -ne 0 ]
  then
    echo $pod
    return 1
  else
    k delete pod $pod -n istio-system
  fi
}

aerakictl_aeraki_log()
{
  pod=`aerakictl_get_pod aeraki istio-system`
  if [ $? -ne 0 ]
  then
    echo $pod
    return 1
  else
    k logs $@ $pod -n istio-system
  fi
}

aerakictl_dangerous_delete_pod()
{
  if [ $# -eq 0 ]
  then
    echo "Please specify app and namespace in the parameters, like \"aerakictl_sidecar_config productpage default\" , if namespace is default, the second parameter can leave unspecied."
  else
    pod=`aerakictl_get_pod $1 $2`
    if [ $? -ne 0 ]
    then
      echo $pod
      return 1
    else
      if [ $# -eq 1 ]
      then
        k delete po $pod
      else
        k delete po $pod -n $2
      fi
    fi
  fi
}
