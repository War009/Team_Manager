# Executive Command Center: Employee Management & Analytics

The **Executive Command Center** is a comprehensive, data-driven mobile application designed for modern team management and organizational oversight. Built with Flutter, this platform bridges the gap between administrative data management and high-level strategic decision-making.

## Overview
Managers are often burdened by fragmented data. This application centralizes human resource management by combining a robust **Employee Directory (CRUD)** with a sophisticated **Analytics Dashboard**. It enables managers to not only track who is in the company but to understand *how* the company is performing in real-time.

## Key Features

### Intelligent Directory Management
Seamlessly add, view, update, and remove employee records. The system provides real-time visibility into headcount and salary benchmarks.

### Strategic Analytics Dashboard
*   **Performance vs. Cost Matrix:** A quadratic analysis tool to map employee productivity against their salary, identifying 'Star' performers and investment opportunities.
*   **Departmental Efficiency Heatmaps:** Visualize the output and health of individual departments at a glance.
*   **Financial Resource Allocation:** Interactive pie charts detailing payroll distribution and departmental budget breakdowns.

### AI-Powered Forecasting
The app includes a "Generative AI" insights engine that analyzes attendance, quality, and productivity metrics to provide automated talent classification (e.g., "Rising Talent") and actionable HR recommendations [cite: Screenshot_2026-06-23-18-07-49-916_com.example.employee_management.jpg, Screenshot_2026-06-23-17-47-13-953_com.example.employee_management.jpg, Screenshot_2026-06-23-17-47-19-948_com.example.employee_management.jpg].

### Advanced Data Visualization
Leveraging the power of the `fl_chart` library to provide professional, readable graphs on staffing trends, tech stack frequency, and departmental budgets.

## Technical Architecture
*   **Framework:** Flutter (Dart)
*   **State Management:** Provider (ensures reactive UI updates across the Directory and Admin modules)
*   **Data Visualization:** `fl_chart`
*   **UI/UX:** Material Design 3 (Dark Mode optimized)
*   **Target:** Android (Developed via Android Studio)

## Purpose
This project was developed as a semester-end mobile application development project to demonstrate proficiency in:
*   **Complex State Management:** Syncing data across multiple views.
*   **Data Science Integration:** Visualizing and interpreting raw business metrics.
*   **Clean UI/UX:** Creating enterprise-grade interfaces that prioritize data readability.
