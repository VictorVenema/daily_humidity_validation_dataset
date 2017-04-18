function dirsOut = remove_invisible_dirs(dirs)

noDirs = numel(dirs);
iDirOut = 0;
for iDir = 1:noDirs
    if ( strncmp(dirs(iDir).name(1), '.', 1) == 0 )
        iDirOut = iDirOut + 1;
        dirsOut(iDirOut) = dirs(iDir); %#ok<AGROW>
    end
end