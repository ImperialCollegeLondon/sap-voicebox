% demonstrations for the v_spgrambw tutorial
clear all;
close all;
p={1 2.5 'pJcwat' [] [] [] [] 2;
    2 1.33 'pc' [] [] [] [] 0;
    3 1.33 'pjc' [] [] [] [] 0;
    4 1.33 'pJc' [] [] [] [] 0;
    5 1.33 'pi' [] [] [] [] 0;
    6 1.33 'pji' [] [] [] [] 0;
    7 1.33 'pJi' [] [] [] [] 0;
    8 1.33 'pJcl' 80 [] [] [] 0;
    9 1.33 'pJce' 80 [] [] [] 0;
    10 1.33 'pJcm' 80 [] [] [] 0;
    11 1.33 'pJcb' 80 [] [] [] 0;
    12 1.33 'pJcbf' 80 [] [] [] 0;
    13 1.33 'hpJc' [] [4000] [] [] 0;
    14 1.33 'hpJc' [] [2000 4000] [] [] 0;
    15 1.33 'hpJc' [] [2000 200 4000] [] [] 0;
    16 1.33 'pJcwat' [50] [] [] [] 1;
    17 1.33 'pJcwat' [] [] [] [] 1;
    18 1.33 'pJcwat' [400] [] [] [] 1;
    19 1.33 'pJcwat' [20] [] [] [] 1;
    20 1.33 'pJcwat' [20] [] [] [0.005] 1;
    21 1.33 'pJcwat' [20] [] [] [1.1 0.001 1.4] 1;
    22 1.33 'Jc' [] [] [] [] 0;
    23 1.33 'pJc' [] [] [] [] 0;
    24 1.33 'PJcbf' [] [] [] [] 0;
    25 1.33 'Jc' [] [] [] [] 0;
    26 1.33 'Jc' [] [] [60] [] 0;
    27 1.33 'Jc' [] [] [-25 0] [] 0;
    28 1.33 'Jcw' [] [] [] [] 0;
    29 1.33 'Jc' [] [] [] [] 1;
    30 1.33 'Jcwat' [] [] [] [] 2};
yfig=420;  % height of figures
emf=1;       % set to 1 to print
args={'BW' 'FMAX' 'DB' 'TINC'};

% read the SFS-format speech file

fn='at05f0.sfs';
[sp,fs]=v_readsfs(fn,1,1);  % speech signal
[pt,fw]=v_readsfs(fn,5,2);    % phonetic transcription
ann=[mat2cell([cell2mat(pt(:,1)) cell2mat(pt(:,1:2))*[1;1]]/fw,ones(1,size(pt,1))) pt(:,3)];
ipa=ann(:,[1 2 2]);
ipa(:,2)={'s' 'I' 'k' 's' 'p' 'l' 'Ã' 's' 'T' 'r' 'i' 'i' 'k' 'w' '«' 'z' 'n' 'aI' 'n' ' '}';
ipa(:,3)=repmat({'SILDoulos IPA93'},size(ipa,1),1);


for i=1:size(p,1)
    if p{i,1}>0
        figure(p{i,1})
        set(gcf,'Position',[100 100 round(yfig*p{i,2}) yfig],'InvertHardcopy','off');
        switch p{i,8}
            case 0
                v_spgrambw(sp,fs,p{i,3},p{i,4},p{i,5},p{i,6},p{i,7});
            case 1
                v_spgrambw(sp,fs,p{i,3},p{i,4},p{i,5},p{i,6},p{i,7},ann);
            case 2
                v_spgrambw(sp,fs,p{i,3},p{i,4},p{i,5},p{i,6},p{i,7},ipa );
        end
        ss=sprintf('%d: MODE=''%s''',p{i,1},p{i,3});
        for j=4:7
            if numel(p{i,j})==1
                ss=sprintf('%s, %s=%g',ss,args{j-3},p{i,j});
            elseif numel(p{i,j})>1
                ss=sprintf('%s, %s=[%s',ss,args{j-3},sprintf('%g ',p{i,j}));
                ss=[ss(1:end-1) ']'];
            end
        end
        title(ss);
         if emf, v_fig2pdf; end
        if i>1 && i<28
            close(i);
        end
    end
end

% now plot other graphs

for i=201:201
    figure(i)
    switch i
        case 201
            fax=linspace(0,6000,200)';
            y=[fax [nan; log10(fax(2:end))] v_frq2mel(fax) v_frq2bark(fax) v_frq2erb(fax)];
            [v,iv]=min(abs(fax-1000));
            y=y./repmat(y(iv,:),length(fax),1);
            plot(fax/1000,y);
            set(gca,'ylim',[0 3]);
            xlabel('Frequency (kHz)');
            ylabel('Scale relative to 1 kHz');
            title('Frequency scales')
            txt={2.8 2.7 'lin'; 5 1.1 'log'; 4.7 2.5 'mel'; 5.2 2.15 'bark'; 4.5 1.7 'erb-rate'};
            for j=1:5
                text(txt{j,1},txt{j,2},txt{j,3})
            end
            v_figbolden
    end
    if emf, v_fig2pdf; end
    close(i);
end
v_tilefigs;


