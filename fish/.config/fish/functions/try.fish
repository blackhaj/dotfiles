# Wraps the try bun script so that cd works in the current shell session
function try
    set -l dir (command try $argv)
    and cd $dir
end
