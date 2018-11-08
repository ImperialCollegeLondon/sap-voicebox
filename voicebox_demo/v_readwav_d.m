% v_spgrambw_d
%
% read speech signal
%
fb='.\data\as01b0';
[s,fs]=readwav(fb);
%
% read word annotations
%
fid=fopen([fb '.wrd']);
can=textscan(fid,'%d%d%s');
fclose(fid);
ann=cell(size(can{1},1),2);
ann(:,1)=num2cell(double([can{1} can{2}])/fs,2);
ann(:,2)=can{3};
%
% plot the spectrogram
%
v_spgrambw(s,fs,'pJcwta',[],[],[],[],ann);
%
% play the sound
%
soundsc(s,fs);