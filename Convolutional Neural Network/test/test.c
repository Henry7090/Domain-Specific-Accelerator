#include<stdio.h>
#include <stdlib.h>
#include <time.h>



int main()
{
    
    

    // Initialize 12x12 image matrix
    float img[144];
    float weight[25];
    int index = 0;
    int ans_index = 0;
    float answer[64];

    for (int i = 0; i < 144; i++) {
        img[i] = (i+1); // Fill with values 1 to 144
    }

    // Initialize 5x5 weight matrix
    
    for (int i = 0; i < 25; i++) {
        weight[i] = i + 1; // Fill with values 1 to 25
    }


    
    
    
    
    
    for(int i = 0;i<144;i++){
       *(float volatile *)0xC4400004 = img[i];
    }
    for(int i = 0;i<25;i++){
        *(float volatile *)0xC4400000 = weight[i];
    }
    

    
    printf("%f\n", answer[0]);
    for(int i = 0;i < 8;i++){
        for(int j = 0;j<8;j++){
            *(int volatile *)0xC4400008 = index;
            answer[ans_index] = *(float volatile *)0xC440000c;
            if(index%12 == 7){
                index += 5;
            }
            else{
                index++;
            }
            ans_index++;

        }
    }
    for(int i=0;i<8;i++){
        for(int j=0;j<8;j++){
            printf("%f ", answer[j+8*i]);
        }
        printf("\n");
    }

    printf("\nsecond time\n");
    // second time
    for (int i = 0; i < 144; i++) {
        img[i] = (i+2); // Fill with values 1 to 144
    }

    for (int i = 0; i < 25; i++) {
        weight[i] = (i + 2); // Fill with values 1 to 25
    }

    for(int i = 0;i<144;i++){
        // printf("img[i] = %f\n", img[i]);
       *(float volatile *)0xC4400004 = img[i];
    }
    for(int i = 0;i<25;i++){
        *(float volatile *)0xC4400000 = weight[i];
    }
    index = 0;
    ans_index = 0;
    for(int i = 0;i < 8;i++){
        for(int j = 0;j<8;j++){
            *(int volatile *)0xC4400008 = index;
            answer[ans_index] = *(float volatile *)0xC440000c;
            if(index%12 == 7){
                index += 5;
            }
            else{
                index++;
            }
            ans_index++;

        }
    }
    for(int i=0;i<8;i++){
        for(int j=0;j<8;j++){
            printf("%f ", answer[j+8*i]);
        }
        printf("\n");
    }

}

