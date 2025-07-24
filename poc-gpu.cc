#include <iostream>
#include <vector>

//using namespace std;
void yval_mod (int label_mod, int64_t rows) {
    std::cout << "beginning\n" << std::endl;
    for (int64_t i = 0; i < 10; ++i) {
        std::cout << "Testing value is: " << i << "] = " << std::endl;
    }
    auto* yval = new std::vector<int32_t>(rows);
    for (int64_t i = 0; i < rows; ++i) {
        (*yval)[i] = static_cast<int>((i % label_mod) + 1);   // 1-based
        std::cout << "yval[" << i << "] = " << (*yval)[i] << std::endl;
    }
    std::cout << "Ending\n" << std::endl;
    for (int64_t i = 0; i < 10; ++i) {
        std::cout << "Ending Testing value is: " << i << "] = " << std::endl;
    }


}


int main () {
    int64_t rows = 4096;
    int label_mod = 2;
    yval_mod(label_mod, rows);
    return 0;
}