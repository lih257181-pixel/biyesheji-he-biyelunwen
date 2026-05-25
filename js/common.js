var CT = CT || {};
CT.alert = function(msg, url) {
    if (confirm(msg)) { location.href = url || '#'; }
};
