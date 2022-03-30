function p = classify(feat)

disp('detecting hydrocephalus ...');
load('hydroClassifier.mat','v');
eta = [feat 1]*v;
p = exp(eta.*1 - log(1+exp(eta)));