# UpdateIPGroupsFromTags
Updates IP groups used by azure firewall for rules by matching VMs with firewallpolicy tags that match the ipgroups firewallpolicy tag.

Run in a scheduler such as Azure Automation on a recurring basis to make firewall rules dynamic based on tags for much simpler management.

Be aware that while updating an IP group is extremely quick, if it has has an associated Azure firewall rule that rule has to be re-provisioned (automatically) and it takes ~3 minutes.  
This is only an issue as it causes the script to run long if you have a lot of IP Groups in a lot of rules, beware of the overall run time.  
A future improvement could be spinning off separate update jobs to essentially make this multi-threaded.

Needs testing against a multi-subscription environment
Needs scale perf testing.
