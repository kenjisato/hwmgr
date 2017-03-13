# hwmgr : homework manager for github classroom

## Setup GitHub {#setup-github}

1. [Get a personal access token](https://github.com/settings/tokens).
   - Select `repo` and `admin:org` scopes.
2. In `~/.Renviron` file, add a line as below. If you don't know what `~` means, 
   type `path.expand("~")` on the R console.
```
GITHUB_PAT = "thelongsequenceofalphanumericcharacters"
```
3. [Create an organization for the course](https://github.com/organizations/new).
   - There seems to be no API for individual users.
   - You may want to [request a discount](https://education.github.com/discount_requests/new) 
     to create private repositories. **This takes time.**
   
## Install `hwmgr` {#install-hwmgr}

1. Install devtools if you haven't done this yet.
```
install.packages("devtools")
```
2. Install `hwmgr` package by 
```
devtools::install_github("kenjisato/hwmgr")
```
3. Make a course directory by
```
hwmgr::start_course("my_course")
```
   This command creates the following directory structure.
```
my_course/
├── assignments/
├── collected/
├── config.yml
├── solutions/
└── templates/
    └── blank/
        └── README.md
```
   - `assignments/` directory populates all assignments.
   - `collected/` directory populates solutions submitted by students.
   - `config.yml` is the configuration file. **Open and edit**.
   - `solutions/` include suggested solutions.
   - `templates/` directory has templates for assignments.
4. Modify `config.yml` file. 
   - The `course.github` entry should be identical to the organization name you 
     chose for the organization ([Step 3 of the previous section](#setup-github)). 
5. Move to `my_course` directory and set it to the working directory.

## Create an assignment with `hwmgr` {#create-an-assignment}

1. Create an assignment by
```
hwmgr::hw_init("homework-name", "short description", template = "blank")
```
   - This function call makes `assignments/homework-name` directory. 
   - Template in `templates/blank` will be copied into there.
   - You can modify these behaviors by properly setting `config.yml`.
2. `assignments/homework-name` is now a git repository, whose `origin` is set to a
   newly created `org/homework-name` repository.
3. Edit template, add, commit, and push.

## Distribute the assignment with GitHub Classroom.

1. Go to [GitHub Classroom website](https://classroom.github.com/classrooms).
2. Click "New classroom"
3. If you see the organization, click it. Otherwise, click the "grant us access" link.
4. ...
5. Choose the repository you've pushed in the previous section as the starter code.
6. ...

Follow the instruction.



