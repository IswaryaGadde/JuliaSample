#Course: CS 524 Principles of programimg language
#Instructor: Mr. Williamson James
#Asssinment: #2
#Author: Iswarya Gadde (A25341583)
#File: 524Program2.jl
#julia version: 1.10.4
#Date: 06-24-2024 
#Environment: VScode (Visual studio code), Julia version 1.10.4, Operating System: Windows

# Description: This program reads student data from an input file, processes test and homework grades,
# and calculates the overall weighted average for each student. It then displays a grade
# report sorted by student last name and first name.
# also produced a second report with the report ordered, descending by each student’s course average.

using Printf
using DelimitedFiles

# Define the Student struct
struct Student
    FirstName::String
    LastName::String
    Tests::Vector{Float64}
    Homeworks::Vector{Float64}
end

# Helper function to parse a line of float values
function parse_floats(line::String)
    return parse.(Float64, split(line))
end

# Function to read student data from a file
function read_students(filename::String)
    lines = readdlm(filename, '\n', String)
    students = Student[]
    i = 1
    while i <= length(lines)
        names = split(lines[i])
        first_name = names[1]
        last_name = names[2]
        i += 1
        test_scores = parse_floats(lines[i])
        i += 1
        homework_scores = parse_floats(lines[i])
        push!(students, Student(first_name, last_name, test_scores, homework_scores))
        i += 1
    end
    return students
end

# Helper function to calculate the sum of a vector
function sum_array(numbers::Vector{Float64})
    return sum(numbers)
end

# Helper function to format scores as a string
function format_scores(scores::Vector{Float64})
    return join([@sprintf("%.1f", score) for score in scores], " ")
end

# Function to calculate the weighted average for a student
function calculate_student_average(student::Student, test_weight::Float64, homework_weight::Float64, num_tests::Int, num_homeworks::Int)
    test_avg = sum_array(student.Tests) / num_tests
    homework_avg = sum_array(student.Homeworks) / num_homeworks
    return (test_avg * test_weight) + (homework_avg * homework_weight)
end

# Function to calculate the overall class average
function calculate_overall_average(students::Vector{Student}, test_weight::Float64, homework_weight::Float64, num_tests::Int, num_homeworks::Int)
    total_average = 0.0
    for student in students
        student_avg = calculate_student_average(student, test_weight, homework_weight, num_tests, num_homeworks)
        total_average += student_avg
    end
    return total_average / length(students)
end

# Function to generate the grade report
function generate_report(students::Vector{Student}, test_weight::Float64, num_tests::Int, num_homeworks::Int)
    # Sort by last name, then first name
    sort!(students, by = x -> (x.LastName, x.FirstName))
    
    homework_weight = 1.0 - test_weight
    overall_average = calculate_overall_average(students, test_weight, homework_weight, num_tests, num_homeworks)

    @printf("GRADE REPORT --- %d STUDENTS FOUND IN FILE\n", length(students))
    @printf("TEST WEIGHT: %.1f%%\n", test_weight * 100)
    @printf("HOMEWORK WEIGHT: %.1f%%\n", homework_weight * 100)
    @printf("OVERALL AVERAGE is %.1f\n", overall_average)
    println("STUDENT NAME :       TESTS        HOMEWORKS          AVG")
    println("---------------------------------------------------------")

    for student in students
        test_count = length(student.Tests)       
        homework_count = length(student.Homeworks)
        average = calculate_student_average(student, test_weight, homework_weight, num_tests, num_homeworks)
        @printf("%s, %s :   %s (%d)   %s (%d)    %.1f", student.LastName, student.FirstName, format_scores(student.Tests), test_count, format_scores(student.Homeworks), homework_count, average)
        if test_count < num_tests
            println(" ** may be missing a test **")
        else
            println()
        end

        if homework_count < num_homeworks
            println(" ** may be missing a homework **")
        else
            println()
        end
    end

    println("\nGRADE REPORT (by course average with descending order.)")
    # Sort by descending course average
    sort!(students, by = x -> -calculate_student_average(x, test_weight, homework_weight, num_tests, num_homeworks))

    for student in students
        test_count = length(student.Tests)       
        homework_count = length(student.Homeworks)
        average = calculate_student_average(student, test_weight, homework_weight, num_tests, num_homeworks)
        @printf("%s, %s :   %s (%d)   %s (%d)    %.1f", student.LastName, student.FirstName, format_scores(student.Tests), test_count, format_scores(student.Homeworks), homework_count, average)
        if test_count < num_tests
            println(" ** may be missing a test **")
        else
            println()
        end
        if homework_count < num_homeworks
            println(" ** may be missing a homework **")
        else
            println()
        end
    end
end

# Main function to run the program
function main()
    println("Enter the name of your input file: ")
    input_file = readline()

    students = read_students(input_file)

    println("Enter the % amount to weight test in overall avg: ")
    test_weight = parse(Float64, readline()) / 100.0

    println("How many homework assignments are there? ")
    num_homeworks = parse(Int, readline())

    println("How many test grades are there? ")
    num_tests = parse(Int, readline())

    generate_report(students, test_weight, num_tests, num_homeworks)
end

main()
