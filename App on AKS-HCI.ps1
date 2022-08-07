#//"My Internal Consumption" 1d1ad10f-f7ee-4d95-b79e-0287e9fe4d64
$SubName = "Azure Hybrid Demo Creation"
$SubID = "03d13178-3e31-454d-9bdd-9e93bc53828a"

$MyRG = "myResourceGroup"
$MyAKSCluster = "myAKSCluster"
$MyAppRepoOption1 = "https://github.com/aaaboulmagd/WebAppForDemos/toarcwithcd/webappfordemo.yml" #"https://raw.githubusercontent.com/aaaboulmagd/AzaksTest/main/webappfordemo.yml"
$MyAppRepoConfigLoc = "https://github.com/aaaboulmagd/WebAppForDemos.git"

#---Get on the right subscription
Get-AzContext #check subscription 
Select-AzSubscription -SubscriptionId $SubID

#---create Resorce Group
az group create --name $MyRG --location westeurope

#---create AKS with 1 node (will take 5 min)
az aks create --resource-group $MyRG --name $MyAKSCluster --node-count 1 --enable-addons monitoring --generate-ssh-keys
#az arcdata dc create --profile-name azure-arc-aks --name aksfromps1onhci --subscription $SubID --resource-group $MyRG --location westeurope --connectivity-mode indirect --use-k8s  --k8s-namespace default

#---Get Credentials so you can manipulate the env
az aks get-credentials --resource-group $MyRG --name $MyAKSCluster

#---Option 1 Deploy an app
kubectl apply -f $MyAppRepoOption1

#---Option 2 Deploy an app
#kubectl apply -f https://raw.githubusercontent.com/aaaboulmagd/AzaksTest/main/Azure-Vote.yaml

#---get the IP so you can see it in the browser 
kubectl get service azure-vote-front

#---redeploy so you can see changes you commited after inishal deployment
#kubectl rollout restart deployment/azure-vote-front

#Start-Process msedge 20.31.81.128

#---Flux Extention # for Arc -t connectedClusters
az k8s-extension create --name FluxExt --resource-group myResourceGroup --cluster-name myAKSCluster -t managedClusters --extension-type microsoft.flux
az k8s-configuration flux create -n myclusterconfigname -g $MyRG -c $MyAKSCluster --namespace mycluster-config-namesapce -t managedClusters --scope cluster -u $MyAppRepoConfigLoc --branch toarcwithcd --kustomization name=myinfraconfig path=./Env/dev prune=true
#az k8s-configuration flux create -n myclusterconfigname -g $MyRG -c $MyAKSCluster --namespace default -t managedClusters --scope cluster -u $MyAppRepoConfigLoc --branch toarcwithcd --kustomization name=myinfraconfig path=./Env/dev prune=true

#-----------
#My clean up
az group delete --name $MyRG
az group delete --name DefaultResourceGroup-WEU
az group delete --name MC_myResourceGroup_myAKSCluster_westeurope
az group delete --name NetworkWatcherRG