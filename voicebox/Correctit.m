% correct error in updating voicebox website
m='v';
fn='.'; % do files in current folder
ff=v_regexfiles('\.m$',fn,'n');
n=0;
for i=1:length(ff)
    fid=fopen(ff{i},'rt');
    s=fread(fid,'*char')';
    fclose(fid);
    t=regexprep(s,'hp/staff/dmb/voicebox/voicebox','hp/staff/dmb/voicebox/voicebox'); % correct web address
    if numel(t)~=numel(s)
        fid=fopen(ff{i},'wt');
        if fid<0
            error(sprintf('Cannot write to %s\n',ff{i}));
        end
        fwrite(fid,t,'*char');
        fclose(fid);
        n=n+1;
        if any(m=='v')
            nch=floor((length(t)-length(s))/2);
            if nch>1
                fprintf(1,'%d changes in %s\n',nch,ff{i});
            else
                fprintf(1,'%d change in %s\n',nch,ff{i});
            end
        end
    elseif any(m=='v')
        fprintf(1,'No changes in %s\n',ff{i});
    end
end
if ~any(m=='s')
    if any(m=='v') && n>0
        fprintf(1,'===========\n');
    end
    fprintf(1,'%d of %d files updated\n',n,length(ff));
end
