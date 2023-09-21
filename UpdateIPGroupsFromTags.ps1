# authenticate
Connect-AzAccount -Identity #-Subscription $AzID
# Set-AzContext -SubscriptionID $AzID

# Get all the IP groups in your subscription
$ipGroups = Get-AzIpGroup

# Loop through each IP group
foreach ($ipGroup in $ipGroups) {

    # Get the tags for the IP group
    $tags = Get-AzTag -ResourceId $ipGroup.Id

    # Filter the tags by name
    $firewallPolicy = $tags.Properties.TagsProperty.FirewallPolicy

    # Display the value of the tag
    Write-Output "IP group: $($ipGroup.Name)"
    Write-Output "FirewallPolicy Tag: $firewallPolicy"

    if ($firewallPolicy -ne $null)
    {

        # Get all the virtual machines in your subscription
        $vms = Get-AzVM

        # Create an empty array to store the IP addresses to be added
        $ipAddresses = @()

	Write-Output "Finding VMs with a matching FirewallPolicy tag"

        # Loop through each virtual machine
        foreach ($vm in $vms) {

            # Get the tags for the virtual machine
            $vmTags = Get-AzTag -ResourceId $vm.Id

            # Check if the virtual machine has the same tag and value as the IP group
            if ($vmTags.Properties.TagsProperty.FirewallPolicy -eq $firewallPolicy) {

                # Get the IP address of the virtual machine
                $ipAddress = (Get-AzNetworkInterface -ResourceGroupName $vm.ResourceGroupName -Name $vm.NetworkProfile.NetworkInterfaces[0].Id.Split('/')[-1]).IpConfigurations[0].PrivateIpAddress

                # Display the name and IP address of the virtual machine
                Write-Output "VM: $($vm.Name), $ipAddress"

                # Add the IP address to the array
                $ipAddresses += $ipAddress
            }
        }
	if ($ipaddresses.count -eq 0) { write-output "No VMs found with a matching tag" }
	if (@(compare-object $ipaddresses $ipgroup.IPaddresses).Length -eq 0) {
		Write-Output "IP Group existing and prospective IP lists are the same, skipping"
	}
	else {
	        # Update the IP group with the new IP addresses
       		$ipGroup.IPAddresses = $ipAddresses
		Write-Output "Setting IP Group ip address list"
        	Set-AzIpGroup -IpGroup $ipGroup

	        # Display a confirmation message
	        Write-Output "IP group updated successfully"
	}
    }
}
