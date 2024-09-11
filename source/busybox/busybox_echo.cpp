#include <stdio.h>

void echo_command(const std::vector<std::string>& args) {
    for (const auto& arg : args) {
        std::cout << arg << " ";
    }
    std::cout << std::endl;
}
