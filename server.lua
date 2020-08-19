RegisterNetEvent('jcrp-toolbox:SendQueueItem')
AddEventHandler('jcrp-toolbox:SendQueueItem', function(data)
    TriggerClientEvent('jcrp-toolbox:AddQueueItem', data.id, data.action, source)
end)

RegisterNetEvent('jcrp-toolbox:SendResponse')
AddEventHandler('jcrp-toolbox:SendResponse', function(data)
    TriggerClientEvent('chat:addMessage', data.id, {
        template = data.msg,
        args = {source, GetPlayerName(source)}
    });
end)