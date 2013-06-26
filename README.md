VMWareGuestDeployer
===================

Bulk deploy of guest VM's from CSV. Automatically chooses correct cluster, best VMFS volume, and best host.

My department was being tasked on a regular basis to deploy large numbers of machines. We run a pretty vanilla installation of ESX. Seperate clusters for Dev/QA and Production. Fancy commercial tools were not available and often too expensive and time consuming to POC and deploy. 

In short, you populate a CSV with machine names, IP addresses, etc and run the script. 

The script then; 
* Chooses the appropriate cluster based on the machine name, ie, LouQa vs. LouPr (QA and Production)
* Finds the VMFS store with the most amount of free space.
* Finds the ESX host with the most amount of free memory.

Based on your static input values in the CSV, (IP, name, template, customization, etc) and the values that are detected, the script deploys machines for you. Sit back and enjoy. 

If you've done everything correctly with your customization spec, your machines should be powered up and joined to your domain; but that's another topic.

Plenty of room here for improvements but this works well for my team. For example, the host with the most free memory might not be the best choice for a deployment target, but DRS does a good job of later moving machines between hosts as needed. 

I would like to be able to deploy more than one machine at a time, but I feel that adds a level of complexity that isn't worth the effort. Again, this works well for my team. 
