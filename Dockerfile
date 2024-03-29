FROM jupyter/r-notebook:latest
 
LABEL maintainer="Alexander Franks <amfranks@ucsb.edu>"

USER root
RUN git clone https://github.com/TheLocehiliosan/yadm.git /usr/local/share/yadm && \
    ln -s /usr/local/share/yadm/yadm /usr/local/bin/yadm
 
RUN pip install nbgitpuller && \
    jupyter serverextension enable --py nbgitpuller --sys-prefix
 
RUN pip install jupyter-server-proxy jupyter-rsession-proxy
 
## install R studio
RUN apt-get update && \
    curl --silent -L --fail https://s3.amazonaws.com/rstudio-ide-build/server/bionic/amd64/rstudio-server-1.2.1578-amd64.deb > /tmp/rstudio.deb && \
    echo '81f72d5f986a776eee0f11e69a536fb7 /tmp/rstudio.deb' | md5sum -c - && \
    apt-get install -y /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && apt-get remove -y r-*
ENV PATH=$PATH:/usr/lib/rstudio-server/bin
 
ENV R_HOME=/opt/conda/lib/R
 
## change littler defaults to conda R
ARG LITTLER=$R_HOME/library/littler
RUN echo "local({\n" \
         "   r <- getOption('repos')\n" \
         "   r['CRAN'] <- 'https://cloud.r-project.org'\n" \
         "   options(repos = r)\n" \
         "})\n" > $R_HOME/etc/Rprofile.site && \
         \
         R -e "install.packages(c('littler', 'docopt'))"
RUN sed -i 's/\/usr\/local\/lib\/R\/site-library/\/opt\/conda\/lib\/R\/library/g' $LITTLER/examples/*.r && \
        ln -s $LITTLER/bin/r $LITTLER/examples/*.r /usr/local/bin/ && \
        echo "$R_HOME/lib" | sudo tee -a /etc/ld.so.conf.d/littler.conf && \
        ldconfig
 
# ggplot2 extensions
RUN install2.r --error \
GGally \
ggridges \
RColorBrewer \
scales \
viridis
 
# Misc utilities
RUN install2.r --error \
beepr \
config \
doParallel \
DT \
foreach \
formattable \
glue \
here \
Hmisc \
httr
 
RUN install2.r --error \
jsonlite \
kableExtra \
logging \
MASS \
microbenchmark \
openxlsx \
pkgdown \
rlang
 
RUN install2.r --error \
RPushbullet \
roxygen2 \
stringr \
styler \
testthat \
usethis  \
ggridges \
plotmo
 
 
# Caret and some ML packages
RUN install2.r --error \
# ML framework
caret \
car \
ensembleR \
# metrics
MLmetrics \
pROC \
ROCR \
# Models
Rtsne \
NbClust
 
RUN install2.r --error \
tree \
maptree \
arm \
e1071 \
elasticnet \
fitdistrplus \
gam \
gamlss \
glmnet \
lme4 \
ltm \
randomForest \
rpart \
# Data
ISLR


RUN conda install -y -c conda-forge r-cairo && \
    install2.r --error imager
 
RUN installGithub.r \
    gbm-developers/gbm3 \
    bradleyboehmke/harrypotter && \
    install2.r --error rstantools shinystan

# More Bayes stuff

RUN install2.r --error \
coda \
loo \
projpred \
MCMCpack \
hflights \
HDInterval \
tidytext \
dendextend \
LearnBayes

USER $NB_USER

#RUN R -e "install.packages(c('coda', 'MCMCpack','faraway', 'MASS', 'nlme', 'lme4', 'car', 'carData', 'effects', 'moderndive', 'optimx', 'roptim', 'quantreg', 'optimParallel', 'ucminf', 'Rcgmin', 'Rtnmin', 'mize', 'nonneg.cg', 'Rsolnp', 'ManifoldOptim', 'gsl', 'neldermead', 'optimsimplex', 'trust', 'trustOptim', 'quantprog', 'coneproj', 'Dykstra', 'limSolve', 'nlsr', 'onls', 'GenSA', 'GA', 'hydroPSO', 'metaheuristicOpt', 'soma', 'NMOF', 'SACOBRA', 'MPV', 'regtools', 'SparseM', 'svd', 'Rlinsolve', 'matrixcalc', 'matlib', 'ggplot2', 'tidyverse', 'Deriv', 'numDeriv', 'pracma', 'SpareGrid', 'Rcpp', 'RcppNumerical', 'calculus', 'akima', 'gss', 'fields', 'sp', 'gstat', 'partitions', 'permutations', 'animation', 'gganimate', 'LearnBayes', 'TeachBayes', 'learnstats', 'visualize', 'TeachingDemos', 'CAR', 'leaps', 'lasso2', 'lars', 'MARS', 'glmnet', 'mgcv', 'ElemStatLearn', 'boot', 'rpart', 'tree', 'ggRandomForests', 'foreign', 'actuar', 'VGAM', 'gamlss.dist', 'MATRIX', 'Sweave', 'lazyWeave', 'knitr', 'Hmisc', 'latex2exp', 'markdown', 'rmarkdown', 'lubridate', 'bibtex', 'tables', 'xtable', 'RefManagerR', 'libprog', 'igraph', 'TSP', 'GPareto', 'dclone', 'tabuSearch', 'maxLik', 'coda', 'MCMCpack', 'tweedie', 'sparseMVN', 'mixtools', 'matrixsampling', 'maps', 'EnvStats', 'circular', 'CircStats', 'foreach', 'biglm', 'biglars', 'ellipse', 'lattice', 'scatterplot3d', 'misc3d', 'geometry', 'vegan', 'aplpack', 'Hmisc', 'ks', 'bayesm', 'pls', 'kernlab', 'concor', 'fastICA', 'psy', 'SensoMineR', 'caret', 'fda', 'class', 'superpc', 'hddplot', 'ade4', 'mvnmle', 'MNP', 'spam', 'abind', 'diagram', 'dynamicGraph', 'DiagrammeR', 'network', 'qgraph', 'Rgraphviz', 'RBGL', 'ggm', 'sna', 'mgm', 'huge', 'parcor', 'gRain', 'boa', 'statnet', 'assist'), repos = 'http://cran.us.r-project.org')"
