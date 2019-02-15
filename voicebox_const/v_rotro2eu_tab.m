% v_rotro2eu_tab: Calculate tables needed for v_rotro2eu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 52 different rotation matrix patterns of -1,0,+1:                     %
%  1- 3: identity matrix rows in order: 123, 231, 312                   % 
%  1- 3: negated identity matrix rows in order: 132, 213, 321           % 
%  7-12: As 1-6 but with rows 2,3 negated                               %
% 13-18: As 1-6 but with rows 1,3 negated                               %
% 19-24: As 1-6 but with rows 1,2 negated                               %
% 25-33: +1 in position (i-24) and 0's in remainder of this row and col %
% 34-42: -1 in position (i-24) and 0's in remainder of this row and col %
% 43-51: 0 in position (i-42)                                           %
% 52: no special symmetry                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mes=[1:3 10:12 7:9 4:6]; % sign reversal look-up table
rtci=[2 3 5 6 8 9; 3 1 6 4 9 7; 1 2 4 5 7 8]';
rtsi=[3 2 6 5 9 8; 1 3 4 6 7 9; 2 1 5 4 8 7]';
rtr=[1 4 7 2 5 8 3 6 9]; % indices to transpose a vectorized 3x3 matrix
w6=ones(6,1); %
th6=3*w6;
x6=[2 1 2 1 2 1]'; % Index for sin components
scai=[0 0 0 1; 0 0 0 2; 0 0 0 3; 1 -1 0 1; 1 -1 0 2; 1 -1 0 3; 0 0 -1 1; 0 0 -1 2; 0 0 -1 3; -1 1 0 1; -1 1 0 2; -1 1 0 3]'; % [sin; -sin; cos; xyz] for fixed rotations
% create pattersn of non-zero entries
nzpatt=10*ones(3,3,52); % pattern of -1,0,+1
e3=eye(3);
nzpatt(:,:,1)=e3;
nzpatt(:,:,2)=e3([2 3 1],:);
nzpatt(:,:,3)=e3([3 1 2],:);
nzpatt(:,:,4)=-e3([1 3 2],:);
nzpatt(:,:,5)=-e3([2 1 3],:);
nzpatt(:,:,6)=-e3([3 2 1],:);
for j=1:3
    f3=-e3;
    f3(j,j)=1;
    for i=1:6
        nzpatt(:,:,i+6*j)=f3*nzpatt(:,:,i);
    end
end
for i=1:9
    ir=1+mod(i-1,3);
    ic=1+(i-ir)/3;
    nzpatt(:,ic,i+24)=0;
    nzpatt(ir,:,i+24)=0;
    nzpatt(ir,ic,i+24)=1;
        nzpatt(:,ic,i+33)=0;
    nzpatt(ir,:,i+33)=0;
    nzpatt(ir,ic,i+33)=-1;
    nzpatt(ir,ic,i+42)=0;
end
nzpattv=reshape(nzpatt,9,52); % vectorize the 3x3 matrices
nzpattc=reshape(sum(nzpatt~=0,1),3,52); % number of non-zero elements in each column
% now create transition map
trmap=zeros(52,12);  % result of applying transformation j to pattern i
zel=zeros(4,3,52); % elements to zero: [zero; non-zero; sine-sign; targ-sign],transformation,initial pattern
jm='xyz123456789'; % rotation patterns
for i=1:52
    for j=1:12
        rijv=reshape(v_rotqr2ro(v_roteu2qr(jm(j),pi/3))*nzpatt(:,:,i),9,1); % vectorized result of applying transformation
        rijv(abs(abs(abs(rijv)-0.5)-0.5)>1e-8)=10; % set entries to 10 unless close to -1,0,+1
        k=find(all(round(rijv)==nzpattv,1),1); % round to integers and find a match
        if isempty(k)
            error('cannot find match for (%d,%d)');
        else
            trmap(i,j)=k;
        end
        if j<=3
            icol=mod(find([nzpattc(:,i)==1 & nzpattc(:,k)==2;nzpattc(:,i)==2 & nzpattc(:,k)==3],1)-1,3)+1; % find the column to zero an element
            if ~isempty(icol)
                irow=(1:3)*(~nzpatt(:,icol,i) & nzpatt(:,icol,k)); % find zero that disappears
                jrow=6-j-irow; % find other row involved in rotation
                zel(:,j,i)=[3*icol-3+[irow; jrow]; mod(j-irow+1,3)-1; sign(nzpatt(jrow,icol,i))];
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print zel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid=fopen('zel.txt','w');
fprintf(fid,'zel=reshape([');
for i=1:52
    if i>1
    fprintf(fid,';\n     '); 
    end
    fprintf(fid,' %2d',zel(:,:,i));
end
fprintf(fid,']'',4,3,52);\n');
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print trmap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid=fopen('trmap.txt','w');
fprintf(fid,'trmap=[');
for i=1:52
    if i>1
    fprintf(fid,';\n     '); 
    end
    fprintf(fid,' %2d',trmap(i,:));
end
fprintf(fid,'];\n');
fclose(fid);



