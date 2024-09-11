#include <fstream>

void cat_command(const std::vector<std::string>& args) {
    if (args.empty()) {
        std::cerr << "cat: missing file operand" << std::endl;
        return;
    }

    std::ifstream file(args[0]);
    if (!file.is_open()) {
        std::cerr << "cat: " << args[0] << ": No such file" << std::endl;
        return;
    }

    std::string line;
    while (std::getline(file, line)) {
        std::cout << line << std::endl;
    }
    file.close();
}
