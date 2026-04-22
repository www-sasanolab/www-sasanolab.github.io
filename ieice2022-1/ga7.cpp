#include &lt;iostream&gt;
#include &lt;iomanip&gt;
#include &lt;vector&gt;
#include &lt;algorithm&gt;
#include &lt;time.h&gt;

#include "create/create.h"

extern int coordinate[31][31];
extern int start_x,start_y;

typedef struct{
	int score;
	std::vector&lt;char&gt; route;
	int pass_miss;
}path;

typedef struct{
	char move;
	int times;
}m_selection;

bool comparisonFunc(const path &a,const path &b);
bool comparisonMselection(const m_selection &a,const m_selection &b);

int main(){

	int len[1024];
	int path_num = 0;
	int parents_num = 0;
	int generation = 1000;
	
	std::cout &lt;&lt; "You can choose generation number: ";
	std::cin &gt;&gt; generation;
	std::cout &lt;&lt; std::endl;
	int generation_n = generation;
	int extension = 0;
	int extension2 = 0;

	int iteration = 1;
	int ite = 1;
	std::cout &lt;&lt; "Decide how many times you want to pass through the cell : ";
	std::cin &gt;&gt; iteration;
	std::cout &lt;&lt; std::endl;
	
	double frequency = 1.0;
	std::cout &lt;&lt; "How many mutations are there ? (Usually once.) :";
	std::cin &gt;&gt; frequency;
	std::cout &lt;&lt; std::endl;
	
	double frequency_tmp = frequency;
	double same_move;
	std::cout &lt;&lt; "If it is the same as previous or next action, what is the frequency?(specify with a decimal point) :";
	std::cin &gt;&gt; same_move;
	std::cout &lt;&lt; std::endl;
	double same_moveBoth;
	std::cout &lt;&lt; "If it is the same as previous and next action, what is the frequency?(specify with a decimal point) :";
	std::cin &gt;&gt; same_moveBoth;
	std::cout &lt;&lt; std::endl;
	double moveFirstf;
	std::cout &lt;&lt; "If the first action is f, what is the frequency?(specify with a decimal point) :";
	std::cin &gt;&gt; moveFirstf;
	std::cout &lt;&lt; std::endl;
	double same_moveFirstf;
	std::cout &lt;&lt; "If the first action is f, and the next action is also f, what is the frequency?(specify with a decimal point) :";
	std::cin &gt;&gt; same_moveFirstf;
	std::cout &lt;&lt; std::endl;

	/*int leave = 3;
	std::cout &lt;&lt; "Decide how much of the mutation you want to keep : ";
	std::cin &gt;&gt; leave;
	std::cout &lt;&lt; std::endl;*/

	srand((unsigned)time(NULL));

	const char *file = "sample";
	FILE *fp = NULL;
	char a[4096];
	int n = 0;
	int tmp_n = 0;

	fp = fopen(file,"r");
	if(fp==NULL){
		std::cout &lt;&lt; file &lt;&lt; " file not open" &lt;&lt; std::endl;
		return 0;
	}

	while(fscanf(fp,"%c",&(a[n])) != EOF){
		while(a[n] != '\n'){
			n++;
			fscanf(fp,"%c",&(a[n]));
		}
		len[path_num]=n-tmp_n;
		path_num++;
		n++;
		tmp_n = n;
	}

	parents_num = path_num / 2;
	fclose(fp);

	std::vector&lt;path&gt; parents(path_num);
	std::vector&lt;path&gt; child(path_num);
	std::vector&lt;path&gt; child_tmp(path_num);
	path child_tmp2;

	for(int i=0;i&lt;path_num;i++){
		parents[i].route.resize(len[i]);
	}
	
	int sum = 0;
	for(int i=0;i&lt;path_num;i++){
		for(int j=0;j&lt;len[i];j++) parents[i].route[j] = a[sum+j];
		sum = len[i] + sum + 1;
	}

	for(int i=0;i&lt;path_num;i++){
		for(int j=0;j&lt;len[i];j++) std::cout &lt;&lt; parents[i].route[j];
		start_pos s = map();
		coordinate[s.x][s.y]=1;
		start_x = s.x;
		start_y = s.y;
		parents[i].score = scoreCalc(parents[i].route.data(),len[i]);
		parents[i].pass_miss = checkPassmiss_ite(ite);
		std::cout &lt;&lt; " :this score is " &lt;&lt; parents[i].score &lt;&lt; " and, ";
		std::cout &lt;&lt; "pass miss : " &lt;&lt; parents[i].pass_miss &lt;&lt; std::endl;
	}
	std::cout &lt;&lt; std::endl;	
	
	//ga start.
	while(generation &gt; 0){


		sort(parents.begin(),parents.end(),comparisonFunc);

		//excelent g inherited
		for(int i=0;i&lt;parents_num;i++){
			child[i].route.resize(parents[i].route.size());
		       	child[i] = parents[i];
		}
		for(int i= parents_num;i&lt;path_num;i++){
			child[i].route.resize(parents[i-parents_num].route.size());
		 	child[i] = parents[i-parents_num];
			child_tmp[i].route.resize(child[i].route.size());
			child_tmp[i] = child[i];
		}
		
		for(int i= parents_num;i&lt;path_num;i++){
			int child_psms = child[i].pass_miss; 
			for(unsigned int j=0;j&lt;child[i].route.size();j++){
				
				if(j==0){
					if(child[i].route[j]=='f'){
					       	frequency = moveFirstf;
						if(child[i].route[j]==child[i].route[j+1]) frequency = same_moveFirstf;
					}
					if(child[i].route[j]!='f' && child[i].route[j]==child[i].route[j+1]) frequency = same_move;
				}
				if(j&gt;0 && child[i].route.size()-1&gt;j){
					if(child[i].route[j]==child[i].route[j-1] || child[i].route[j]==child[i].route[j+1]) frequency = same_move;
					if(child[i].route[j]==child[i].route[j-1] && child[i].route[j]==child[i].route[j+1]) frequency = same_moveBoth;
				}
				if(j==child[i].route.size()-1 && child[i].route[j]==child[i].route[j-1]) frequency = same_move;

				if(rand() % int(child[i].route.size()/frequency) == 0){
					int random = rand() % 3;
					char tmp_move = child[i].route[j];
					if(tmp_move == 'f'){
						if(random == 0) child[i].route[j] = 'b';
						else if(random == 1) child[i].route[j] = 'r';
						else if(random == 2) child[i].route[j] = 'l';
					}else if(tmp_move == 'b'){
						if(random == 0) child[i].route[j] = 'f';
						else if(random == 1) child[i].route[j] = 'r';
						else if(random == 2) child[i].route[j] = 'l';
					}else if(tmp_move == 'r'){
						if(random == 0) child[i].route[j] = 'f';
						else if(random == 1) child[i].route[j] = 'b';
						else if(random == 2) child[i].route[j] = 'l';
					}else{
						if(random == 0) child[i].route[j] = 'f';
						else if(random == 1) child[i].route[j] = 'b';
						else if(random == 2) child[i].route[j] = 'r';
					}
					
					std::vector&lt;char&gt; route_mid;
					route_mid.resize(j+1);
					for(unsigned int m=0;m&lt;j+1;m++) route_mid[m] = child[i].route[m];

					start_pos s = map();
					coordinate[s.x][s.y]=1;
					start_x = s.x;
					start_y = s.y;
					move_count mutant = moveEmu(route_mid.data(),j+1);

					if(mutant.conflict_n &gt; 0) child[i].route[j] = tmp_move;
					else{
						s=map();
						coordinate[s.x][s.y]=1;
						start_x = s.x;
						start_y = s.y;
						move_count mutan = moveEmu(child[i].route.data(),child[i].route.size());
						child[i].pass_miss = checkPassmiss_ite(ite);

						if(child[i].pass_miss&gt;child_psms || mutan.conflict_n&gt;0){
							s=map();
							coordinate[s.x][s.y]=1;
							start_x = s.x;
							start_y = s.y;
							position area = moveFinish(child[i].route.data(),j+1);
							std::vector&lt;m_selection&gt; neigh(4);
							for(unsigned int m=j+1;m&lt;child[i].route.size();m++){
								neigh[0].times=coordinate[start_x+area.x][start_y+area.y-1];
								neigh[0].move='f';
								neigh[1].times=coordinate[start_x+area.x+1][start_y+area.y];
								neigh[1].move='r';
								neigh[2].times=coordinate[start_x+area.x-1][start_y+area.y];
								neigh[2].move='l';
								neigh[3].times=coordinate[start_x+area.x][start_y+area.y+1];
								neigh[3].move='b';

								sort(neigh.begin(),neigh.end(),comparisonMselection);
								int min_n=1;
								int min = neigh[0].times;
								for(int u=1;u&lt;4;u++){
									if(min==neigh[u].times) min_n++;
								}
								char sel_m[min_n];
								for(int u=0;u&lt;min_n;u++) sel_m[u]=neigh[u].move;

								char selected_m;
								if(min_n==1) selected_m = neigh[0].move;
								else if(min_n==2){
									int ran = rand()%2;
									selected_m = sel_m[ran];
								}else if(min_n==3){
									int ran = rand()%3;
									selected_m = sel_m[ran];
								}else if(min_n==4){
									int ran = rand()%4;
									selected_m = sel_m[ran];
								}

								child[i].route[m]=selected_m;
								s=map();
								coordinate[s.x][s.y]=1;
								start_x = s.x;
								start_y = s.y;
								area = moveFinish(child[i].route.data(),m+1);
							}
						}
					}
				}
				frequency = frequency_tmp;
				start_pos s=map();
				coordinate[s.x][s.y]=1;
				start_x = s.x;
				start_y = s.y;
				child[i].score = scoreCalc(child[i].route.data(),child[i].route.size());
				child_psms = checkPassmiss_ite(ite);
			        	
			}
			if(child_tmp[i].route != child[i].route){
			
				start_pos s = map();
				coordinate[s.x][s.y]=1;
				start_x = s.x;
				start_y = s.y;
				child[i].score = scoreCalc(child[i].route.data(),child[i].route.size());
				child[i].pass_miss = checkPassmiss_ite(ite);

				if(child[i].pass_miss&gt;child_tmp[i].pass_miss){
					//child_tmp2.route.resize(child[i].route.size());
					//child_tmp2 = child[i];
					child[i] = child_tmp[i];
					//if(rand()%leave == 0) child[i] = child_tmp2;
				}
			}
		}
		for(int i=0;i&lt;path_num;i++){
			parents[i].route.resize(child[i].route.size());
		       	parents[i] = child[i];
		}

		generation -= 1;

		if(generation==0 && parents[0].pass_miss!=0){
			generation += generation_n;
			if(ite == 1){
			       	extension += 1;
				std::cout &lt;&lt; "now,extension: " &lt;&lt; extension &lt;&lt; std::endl;
			}else{
			       	extension2 += 1;
				std::cout &lt;&lt; "now,extension2: " &lt;&lt; extension2 &lt;&lt; std::endl;
			}
		}else if(generation==0 && parents[0].pass_miss==0){
			for(int i=0;i&lt;path_num;i++){

				
				for(unsigned int j=0;j&lt;parents[i].route.size();j++) std::cout &lt;&lt; parents[i].route[j];
				std::cout &lt;&lt; std::endl;

				start_pos s = map();
				coordinate[s.x][s.y]=1;
				start_x = s.x;
				start_y = s.y;
				
				int cut = moveNum(parents[i].route.data(),parents[i].route.size(),ite);
				parents[i].route.resize(cut+1);

				s = map();
				coordinate[s.x][s.y]=1;
				start_x = s.x;
				start_y = s.y;
				parents[i].score = scoreCalc(parents[i].route.data(),parents[i].route.size());
				parents[i].pass_miss = checkPassmiss_ite(ite);


				for(unsigned int j=0;j&lt;parents[i].route.size();j++) std::cout &lt;&lt; parents[i].route[j];
				std::cout &lt;&lt; ":length : " &lt;&lt; parents[i].route.size() &lt;&lt; std::endl;
				std::cout &lt;&lt; "-----------------------------------" &lt;&lt; std::endl;
				
			}

			if(iteration&gt;1){
				std::cout &lt;&lt; "path expand!" &lt;&lt; std::endl;
				ite = iteration;
				iteration = 1;
				unsigned int size_tmp[path_num];
				for(int i=0;i&lt;path_num;i++){
					unsigned int size = parents[i].route.size();
					parents[i].route.resize(size*ite);
					unsigned int tir =1;
					for(unsigned int j=size;j&lt;parents[i].route.size();j++){
						if(tir&gt;size) tir = 1;

						if(parents[i].route[j-(2*tir-1)]=='f') parents[i].route[j]='b';
						else if(parents[i].route[j-(2*tir-1)]=='b') parents[i].route[j]='f';
						else if(parents[i].route[j-(2*tir-1)]=='r') parents[i].route[j]='l';
						else if(parents[i].route[j-(2*tir-1)]=='l') parents[i].route[j]='r';
						
						tir += 1;
					}
					size_tmp[i]=size;
				}
				//std::cout &lt;&lt; "hey!" &lt;&lt; std::endl;
				
				for(int i=0;i&lt;path_num;i++){
					if(parents[i].route[size_tmp[i]-1]=='f'){
						parents[i].route.insert(parents[i].route.begin()+size_tmp[i],'b');
						parents[i].route.insert(parents[i].route.begin()+size_tmp[i]+1,'f');
					}else if(parents[i].route[size_tmp[i]-1]=='r'){
						parents[i].route.insert(parents[i].route.begin()+size_tmp[i],'l');
						parents[i].route.insert(parents[i].route.begin()+size_tmp[i]+1,'r');
					}else if(parents[i].route[size_tmp[i]-1]=='l'){
						parents[i].route.insert(parents[i].route.begin()+size_tmp[i],'r');
						parents[i].route.insert(parents[i].route.begin()+size_tmp[i]+1,'l');
					}else if(parents[i].route[size_tmp[i]-1]=='b'){
						parents[i].route.insert(parents[i].route.begin()+size_tmp[i],'f');
						parents[i].route.insert(parents[i].route.begin()+size_tmp[i]+1,'b');
					}
				}

				for(int i=0;i&lt;path_num;i++){
					start_pos s;
					s=map();
					coordinate[s.x][s.y]=1;
					start_x = s.x;
					start_y = s.y;
					parents[i].score = scoreCalc(parents[i].route.data(),parents[i].route.size());
					parents[i].pass_miss = checkPassmiss_ite(ite);
				}

				for(int i=0;i&lt;path_num;i++){
					for(unsigned int j=0;j&lt;parents[i].route.size();j++) std::cout &lt;&lt; parents[i].route[j];
					std::cout &lt;&lt; ": socre is " &lt;&lt; parents[i].score;
					std::cout &lt;&lt; ". pass miss is " &lt;&lt; parents[i].pass_miss &lt;&lt; std::endl;
				}
				generation += generation_n;	
			}			
		}
	}

	std::cout &lt;&lt; "parents's final score is " &lt;&lt; parents[0].score &lt;&lt; ". and this pass miss is " &lt;&lt; parents[0].pass_miss &lt;&lt; "." &lt;&lt; std::endl;
	std::cout &lt;&lt; "The number of extensions is " &lt;&lt; extension &lt;&lt; "."  &lt;&lt; std::endl;
	std::cout &lt;&lt; "And this route is "; 
	for(unsigned int i=0;i&lt;parents[0].route.size();i++){
		std::cout &lt;&lt; parents[0].route[i];
	}
	std::cout &lt;&lt; ": character num : " &lt;&lt; parents[0].route.size();
	std::cout &lt;&lt; std::endl;
	 
	return 0;
}


bool comparisonFunc(const path &a,const path &b){
	return a.score &lt; b.score;
}
bool comparisonMselection(const m_selection &a,const m_selection &b){
	return a.times &lt; b.times;
}
