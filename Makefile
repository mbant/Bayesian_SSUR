CC=g++
CFLAGS= -c -Wall -std=c++11 -fopenmp

OPENLDFLAGS= -larmadillo -lpthread -lopenblas -fopenmp
NVLDFLAGS= -larmadillo -lpthread -fopenmp -Llibnvblas.so -Llibcublas.so

SOURCES_BVS=src/global.cpp src/utils.cpp src/distr.cpp src/junction_tree.cpp src/HESS_Chain.cpp src/dSUR_Chain.cpp src/SSUR_Chain.cpp src/ESS_Sampler.h src/drive.cpp 
#ESS_Atom.h interface only
OBJECTS_BVS=$(SOURCES_BVS:.cpp=.o)

all:$(SOURCES_BVS) BVS_NONVIDIA

COMPILE_ONLY: $(OBJECTS_BVS)

BVS_NVIDIA: OPTIM_FLAGS := -O3
BVS_NVIDIA: $(OBJECTS_BVS)
	@echo [Linking and producing executable]:
	if [ -e /usr/lib/libnvblas.so -o -e /usr/lib64/libnvblas.so -o -e /usr/local/cuda/lib/libnvblas.so -o -e /usr/local/cuda/lib64/libnvblas.so ] ; then $(CC) $(OBJECTS_BVS) -o BVS_Reg $(NVLDFLAGS) ; else $(CC) $(OBJECTS_BVS) -o BVS_Reg $(OPENLDFLAGS) ; fi
# I hate that this is searching only in the standard path, the correct way is with automake ./config, but that will come later...

BVS_NONVIDIA: OPTIM_FLAGS := -O3
BVS_NONVIDIA: $(OBJECTS_BVS)
	@echo [Linking and producing executable]:
	$(CC) $(OBJECTS_BVS) -o BVS_Reg $(OPENLDFLAGS)

BVS_DEBUG: $(OBJECTS_BVS)
	@echo [Linking and producing executable]:
	$(CC) $(OBJECTS_BVS) -o BVS_DEBUG_Reg $(LDFLAGS) -ggdb3

%.o: %.cpp
	@echo [Compiling]: $<
	$(CC) $(CFLAGS) $(OPTIM_FLAGS) -o $@ -c $<	

clean: 
	@echo [Cleaning: ]
	rm src/*.o ; rm *_Reg ; rm simul* ; rm call.sh ; rm -R results ;
