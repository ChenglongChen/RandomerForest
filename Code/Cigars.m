%Parallel cigars

close all
clear
clc

n = 1000;
ntrees = 250;
NWorkers = 2;
Class = [0;1];
k = 1;
kk = 4;

poolobj = gcp('nocreate');
if isempty(poolobj)
    parpool('local',NWorkers,'IdleTimeout',360);
end

Mu0 = [-1 0];
Mu1 = [1 0];
Sigma = [k 0;0 kk];
Mu = cat(1,Mu0,Mu1);
obj = gmdistribution(Mu,Sigma);
[X,idx] = random(obj,n);
Y = cellstr(num2str(Class(idx)));
d = size(X,2);
nvartosample = ceil(d^(2/3));
negidx = strcmp(Y,'0');
posidx = strcmp(Y,'1');

%Rotate parallel cigars by 45 degrees
R = [cosd(45) -sind(45);sind(45) cosd(45)];
Xrot = X*R;

subplot(2,3,1)
plot(Xrot(negidx,1),Xrot(negidx,2),'bo',Xrot(posidx,1),Xrot(posidx,2),'rx')
hold on
ax = gca;
Ymax = max(abs(ax.YLim)) + 2;
ax.YLim = [-Ymax Ymax];
ax.XLim = ax.YLim;

rf_rot = rpclassificationforest(ntrees,Xrot,Y,'nvartosample',nvartosample,'RandomForest',true,'NWorkers',NWorkers);

Tree = rf_rot.Tree{1};
noderows = cell(0,length(Tree.node));
noderows{1} = 1:size(X,1);
internalnodes = Tree.node(Tree.var ~= 0);
internalnodes = internalnodes';
leafnodes = Tree.node(Tree.var == 0);
leafnodes = leafnodes';
partitions = [];
i = 1;
for node = internalnodes
    var = Tree.var(node);
    cut = Tree.cut{node};
    par = Tree.parent(node);
    p = [];
    if node == 1
        if var == 1
            lb = ax.YLim(1);
            ub = ax.YLim(2);
            plot([cut cut],[lb ub],'k-')
            hold on
        else
            lb = ax.XLim(1);
            ub = ax.XLim(2);
            plot([lb ub],[cut cut],'k-')
            hold on
        end
    else
        go = var == Tree.var(par);
        j = 1;
        while go
            par(j+1) = Tree.parent(par(j));
            go = var == Tree.var(par(j+1));
            j = j + 1;
        end
        if length(par) == 1
            ch = node;
        else
            ch = par(end-1);
        end
        allch = Tree.children;
        if ch == min(allch(par(end),:))
            ub = Tree.cut{par(end)};
            if var == 1
                is2 = partitions(:,1)==2;
                partitions2 = partitions(is2,:);
                p = partitions2(partitions2(:,2)<ub & partitions2(:,3)<cut & partitions2(:,4)>cut,:);
                if ~isempty(p)
                    lb = p(end,2);
                else
                    lb = ax.YLim(1);
                end
                plot([cut cut],[lb ub],'k-')
                hold on
            else
                is1 = partitions(:,1)==1;
                partitions1 = partitions(is1,:);
                p = partitions1(partitions1(:,2)<ub & partitions1(:,3)<cut & partitions1(:,4)>cut,:);
                if ~isempty(p)
                    lb = p(end,2);
                else
                    lb = ax.XLim(1);
                end
                plot([lb ub],[cut cut],'k-')
                hold on
            end
        else
            lb = Tree.cut{par(end)};
            if var ==1
                is2 = partitions(:,1)==2;
                partitions2 = partitions(is2,:);
                p = partitions2(partitions2(:,2)>lb & partitions2(:,3)<cut & partitions2(:,4)>cut,:);
                if ~isempty(p)
                    ub = p(end,2);
                else
                    ub = ax.YLim(2);
                end
                plot([cut cut],[lb ub],'k-')
                hold on
            else
                is1 = partitions(:,1)==1;
                partitions1 = partitions(is1,:);
                p = partitions1(partitions1(:,2)>lb & partitions1(:,3)<cut & partitions1(:,4)>cut,:);
                if ~isempty(p)
                    ub = p(end,2);
                else
                    ub = ax.XLim(2);
                end
                plot([lb ub],[cut cut],'k-')
                hold on
            end
        end
    end
    %find closest parent of opposite variable
    %right or left determines if upper or lower bound
    
    partitions(i,1) = var;
    partitions(i,2) = cut;
    partitions(i,3) = lb;
    partitions(i,4) = ub;
    i = i + 1;
end

subplot(2,3,2)
plot(Xrot(negidx,1),Xrot(negidx,2),'bo',Xrot(posidx,1),Xrot(posidx,2),'rx')
hold on
ax = gca;
Ymax = max(abs(ax.YLim));
ax.YLim = [-Ymax Ymax];
ax.XLim = ax.YLim;
plot(ax.XLim,kk*ax.XLim,'k-')

subplot(2,3,3)
plot(Xrot(negidx,1),Xrot(negidx,2),'bo',Xrot(posidx,1),Xrot(posidx,2),'rx')
hold on
ax = gca;
Ymax = max(abs(ax.YLim));
ax.YLim = [-Ymax Ymax];
ax.XLim = ax.YLim;
plot(ax.XLim,ax.YLim,'k-')

n = 1000;
ntrees = 250;
NWorkers = 2;
Class = [0;1];
k = 1;
kk = 8;

poolobj = gcp('nocreate');
if isempty(poolobj)
    parpool('local',NWorkers,'IdleTimeout',360);
end

Mu0 = [-1 0];
Mu1 = [1 0];
Sigma = [k 0;0 kk];
Mu = cat(1,Mu0,Mu1);
obj = gmdistribution(Mu,Sigma);
[X,idx] = random(obj,n);
Y = cellstr(num2str(Class(idx)));
d = size(X,2);
nvartosample = ceil(d^(2/3));
negidx = strcmp(Y,'0');
posidx = strcmp(Y,'1');

%Rotate parallel cigars by 45 degrees
R = [cosd(45) -sind(45);sind(45) cosd(45)];
Xrot = X*R;

subplot(2,3,4)
plot(Xrot(negidx,1),Xrot(negidx,2),'bo',Xrot(posidx,1),Xrot(posidx,2),'rx')
hold on
xlim(ax.XLim)
ylim(ax.YLim)

rf_rot = rpclassificationforest(ntrees,Xrot,Y,'nvartosample',nvartosample,'RandomForest',true,'NWorkers',NWorkers);

Tree = rf_rot.Tree{1};
noderows = cell(0,length(Tree.node));
noderows{1} = 1:size(X,1);
internalnodes = Tree.node(Tree.var ~= 0);
internalnodes = internalnodes';
leafnodes = Tree.node(Tree.var == 0);
leafnodes = leafnodes';
partitions = [];
i = 1;
for node = internalnodes
    var = Tree.var(node);
    cut = Tree.cut{node};
    par = Tree.parent(node);
    p = [];
    if node == 1
        if var == 1
            lb = ax.YLim(1);
            ub = ax.YLim(2);
            plot([cut cut],[lb ub],'k-')
            xlim(ax.XLim)
            ylim(ax.YLim)
            hold on
        else
            lb = ax.XLim(1);
            ub = ax.XLim(2);
            plot([lb ub],[cut cut],'k-')
            xlim(ax.XLim)
            ylim(ax.YLim)
            hold on
        end
    else
        go = var == Tree.var(par);
        j = 1;
        while go
            par(j+1) = Tree.parent(par(j));
            go = var == Tree.var(par(j+1));
            j = j + 1;
        end
        if length(par) == 1
            ch = node;
        else
            ch = par(end-1);
        end
        allch = Tree.children;
        if ch == min(allch(par(end),:))
            ub = Tree.cut{par(end)};
            if var == 1
                is2 = partitions(:,1)==2;
                partitions2 = partitions(is2,:);
                p = partitions2(partitions2(:,2)<ub & partitions2(:,3)<cut & partitions2(:,4)>cut,:);
                if ~isempty(p)
                    lb = p(end,2);
                else
                    lb = ax.YLim(1);
                end
                plot([cut cut],[lb ub],'k-')
                xlim(ax.XLim)
                ylim(ax.YLim)
                hold on
            else
                is1 = partitions(:,1)==1;
                partitions1 = partitions(is1,:);
                p = partitions1(partitions1(:,2)<ub & partitions1(:,3)<cut & partitions1(:,4)>cut,:);
                if ~isempty(p)
                    lb = p(end,2);
                else
                    lb = ax.XLim(1);
                end
                plot([lb ub],[cut cut],'k-')
                xlim(ax.XLim)
                ylim(ax.YLim)
                hold on
            end
        else
            lb = Tree.cut{par(end)};
            if var ==1
                is2 = partitions(:,1)==2;
                partitions2 = partitions(is2,:);
                p = partitions2(partitions2(:,2)>lb & partitions2(:,3)<cut & partitions2(:,4)>cut,:);
                if ~isempty(p)
                    ub = p(end,2);
                else
                    ub = ax.YLim(2);
                end
                plot([cut cut],[lb ub],'k-')
                xlim(ax.XLim)
                ylim(ax.YLim)
                hold on
            else
                is1 = partitions(:,1)==1;
                partitions1 = partitions(is1,:);
                p = partitions1(partitions1(:,2)>lb & partitions1(:,3)<cut & partitions1(:,4)>cut,:);
                if ~isempty(p)
                    ub = p(end,2);
                else
                    ub = ax.XLim(2);
                end
                plot([lb ub],[cut cut],'k-')
                xlim(ax.XLim)
                ylim(ax.YLim)
                hold on
            end
        end
    end
    %find closest parent of opposite variable
    %right or left determines if upper or lower bound
    
    partitions(i,1) = var;
    partitions(i,2) = cut;
    partitions(i,3) = lb;
    partitions(i,4) = ub;
    i = i + 1;
end

subplot(2,3,5)
plot(Xrot(negidx,1),Xrot(negidx,2),'bo',Xrot(posidx,1),Xrot(posidx,2),'rx')
hold on
xlim(ax.XLim)
ylim(ax.YLim)
plot(ax.XLim,kk*ax.XLim,'k-')

subplot(2,3,6)
plot(Xrot(negidx,1),Xrot(negidx,2),'bo',Xrot(posidx,1),Xrot(posidx,2),'rx')
hold on
xlim(ax.XLim)
ylim(ax.YLim);
plot(ax.XLim,ax.YLim,'k-')

fname = 'Cigars_rough';
save_fig(gcf,fname)