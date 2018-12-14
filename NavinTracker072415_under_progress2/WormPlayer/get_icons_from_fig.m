% --------------------------------------------------------
function icons = get_icons_from_fig(hfig)

udfig = get(hfig,'userdata');
udtb = getappdata(udfig.htoolbar);
icons = udtb.icons;

% --------------------------------------------------------


