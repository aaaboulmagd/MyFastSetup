#//"My Internal Consumption" 1d1ad10f-f7ee-4d95-b79e-0287e9fe4d64
$SubName = "Azure Hybrid Demo Creation"
$SubID = "03d13178-3e31-454d-9bdd-9e93bc53828a"

$MyRG = "myTempRG"
$MGRG = "cppe-pod04aks-wcus"
$MyAKSCluster = "my-demo-aks-cluster"
$MyFluxConfig = "my-flux-config"
$MyInfraRepo_Web = "https://github.com/aaaboulmagd/WebAppForDemos.git" #"https://raw.githubusercontent.com/aaaboulmagd/AzaksTest/main/webappfordemo.yml"  #"https://raw.githubusercontent.com/aaaboulmagd/AzaksTest/main/webappfordemo.yml"
$MyInfraRepo_Vote = "https://github.com/aaaboulmagd/InfraForDemos.git"

#---Get on the right subscription
Get-AzContext #check subscription 
Select-AzSubscription -SubscriptionId $SubID

#--- Create new cluster 
New-AksHciCluster -name $MyAKSCluster -nodePoolName linuxnodepool -nodeCount 1 -osType Linux

#--- Create new node pool
New-AksHciNodePool -name pool-for-demo -ClusterName $MyAKSCluster #default OS is Linux. For windows use -OSType Windows

#---Get Credentials so you can manipulate the env
Get-AksHciCredential -Name $MyAKSCluster

#---Option 1 Deploy an app
kubectl apply -f "https://raw.githubusercontent.com/aaaboulmagd/InfraForDemos/NewStructure/Web%20App%20For%20Demo/webappfordemoFromDocker.yml"

#---Option 2 Deploy an app
#kubectl apply -f https://raw.githubusercontent.com/aaaboulmagd/InfraForDemos/NewStructure/AzureVoteApp/Azure-Vote.yaml

#---get the IP so you can see it in the browser 
kubectl get service #options -> <<name if servuce>> 

#--- Arc Enable it 
Enable-AksHciArcConnection -name $MyAKSCluster -SubscriptionId $SubID -resourceGroup cppe-pod04aks-wcus -location westcentralus -tenantId c76bd4d1-bea3-45ea-be1b-4a745a675d07
#********Needed For First time *******
#--- install Azure CLI if needed
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
#--- Register Providers 
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.KubernetesConfiguration
#--- Add Extentions 
az extension add -n k8s-configuration
az extension add -n k8s-extension
#*************************************

#--- configuring Flux #-t "managedClusters" for AKS clusters connectedClusters for Arc
az k8s-configuration flux create -n $MyFluxConfig -g $MGRG /
-c $MyAKSCluster /
--namespace flux-cluster-config /
-t connectedClusters /
--scope cluster /
-u $MyInfraRepo_Vote /
--branch NewStructure /
--interval 5s /
--kustomization / 
name=VoteApp-CD path="./AzureVoteApp" /
prune=true


#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
