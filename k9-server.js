onNet('k9:GetPerms', () => {
	const src = source;
    exports.df_Core.CheckPermission(src, ['652990967091167233'], hasPermission => { // First Responder Role
        emitNet('k9:GetPerms:callback', src, hasPermission);
    });
})