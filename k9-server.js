onNet('k9:GetPerms', () => {
    const src = source
    exports.df_Core.DatabaseFindOne('Players', { 'ServerId': src }, PlayerInfo => {
        const PlayerRoles = exports.df_Core.GetPlayerRoles(PlayerInfo.DiscordId);
        const Role = '652990967091167233'; // First Responder Role
        emitNet('k9:GetPerms:callback', src, (PlayerRoles && PlayerRoles.includes(Role)));
    });
})