# Todo App Capstone - Beginner's Guide

## What You're Building

A complete todo list application with:
- **Cloud backend** (AWS): Stores todos in a database
- **Mobile/Web app** (Flutter): Beautiful interface to interact with todos

## Architecture Overview

```
Phone/Browser (Flutter)
    ↓ (HTTP requests)
API Gateway (Front door)
    ↓
Lambda Functions (Code that runs in cloud)
    ↓
DynamoDB (Database)
```

## Step-by-Step Build Process

### Step 1: Build the Backend (30-45 min)
1. Create DynamoDB table (database)
2. Write 4 Lambda functions (cloud code):
   - List todos
   - Create todo
   - Toggle done/not done
   - Delete todo
3. Set up API Gateway (connects app to functions)
4. Deploy to AWS using CDK

### Step 2: Build the Frontend (30-45 min)
1. Create Flutter app
2. Build two screens:
   - List screen (shows all todos)
   - Add screen (creates new todo)
3. Connect to backend API
4. Test everything works

### Step 3: Demo (15 min)
Show it working end-to-end!

## Prerequisites

Before starting, make sure you have:
- ✅ Python 3 (you have 3.9.6)
- ✅ AWS CLI (you have it)
- ⏳ Node.js (need to install)
- ⏳ AWS CDK (need to install)
- ⏳ Flutter (need to install)

## Installation Commands

Run these in your terminal:

```bash
# 1. Install Node.js
brew install node

# 2. Install AWS CDK
npm install -g aws-cdk

# 3. Install Flutter
cd ~
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
flutter doctor

# 4. Configure AWS credentials (if not done)
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter region: us-east-1
# Enter output format: json
```

## Quick Start (After Prerequisites)

```bash
# Navigate to project
cd /Users/udaycharanreddy/bootcamp/todo-capstone

# Deploy backend
cd cdk
pip3 install -r requirements.txt
cdk bootstrap  # First time only
cdk deploy

# Run Flutter app
cd ../flutter
flutter pub get
flutter run -d chrome  # Or: flutter run (for simulator)
```

## Project Structure

```
todo-capstone/
├── README.md (this file)
├── cdk/ (Backend infrastructure code)
│   ├── app.py (Main CDK app)
│   ├── stack.py (Defines AWS resources)
│   └── requirements.txt (Python dependencies)
├── lambda/ (Cloud functions)
│   ├── common.py (Shared code)
│   ├── list_todos.py
│   ├── create_todo.py
│   ├── toggle_todo.py
│   └── delete_todo.py
└── flutter/ (Mobile/Web app)
    ├── lib/
    │   ├── main.dart (App entry point)
    │   ├── screens/ (UI screens)
    │   ├── models/ (Data structures)
    │   └── services/ (API calls)
    └── pubspec.yaml (Flutter dependencies)
```

## Next Steps

1. Read through CAPSTONE_PLAN.md for architecture details
2. Install prerequisites
3. Follow build instructions below
4. Test and demo!

---

Ready? Let's build it step by step!
