# Domain-Specific Accelerator (DSA)

## **Project Overview**
This project implements a **Domain-Specific Accelerator (DSA)** to optimize inner product operations within **Convolutional Neural Networks (CNNs)** for handwriting recognition tasks. The design leverages **`aquila`**, a RISC-V 5-stage pipelined core developed by the **Embedded Intelligence System Lab (EISL)**. The primary focus is on enhancing the performance of **floating-point computations** in the **convolutional layer** and, to a lesser extent, the **fully connected layer**, with significant emphasis on convolution operations.

---

## **Current Progress**

### 1. **Performance Improvements**
- **Execution Time**: Reduced from **21,502 ms** to **2,101 ms**, achieving a **10.23x speedup**.

### 2. **MMIO-Based Communication**
- Implemented **Memory-Mapped I/O (MMIO)** for seamless communication between the CPU and the accelerator, supporting efficient hardware-software co-design.

### 3. **Floating-Point IP Acceleration**
- Integrated three floating-point IP cores in **Vivado**, employing a non-blocking architecture to accelerate inner product computations.
- Optimized floating-point multiplication, addition, and other related operations to minimize bottlenecks.

### 4. **CNN Optimization**
#### **Convolutional Layer Optimization**
- Transferred the **3D convolution (conv3D)** computation entirely to hardware for accelerated performance.
- Workflow: **Image** and **weight** data are transmitted to the hardware, processed, and results are returned efficiently.
- Key updates made to the `convolutional_layer.h` file.

#### **Fully Connected Layer Optimization**
- Improved the efficiency of inner product calculations, enhancing overall CNN performance in this layer.

---

## **Recent Work**

### 1. **Pooling Layer Circuit Design**
- Addressing pooling layer bottlenecks.

---


