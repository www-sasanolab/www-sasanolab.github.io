int main(void){
  typedef union{
    int a;
    double b;
  } ab;
  ab x;
  x.a=3;
  return 0;
}
