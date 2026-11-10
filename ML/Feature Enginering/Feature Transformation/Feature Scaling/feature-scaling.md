# Feature Scaling

## What Is Feature Scaling ?

Feature scaling is a data preprocessing technique used to bring
numerical features into a similar range or scale.

In a dataset, features can have very different values and units. For
example, a person's age may range from 18 to 60, while their annual
income may range from ₹100,000 to ₹2,000,000. Because the values differ
greatly, some machine learning algorithms may give more influence to
features with larger numerical scales.

Feature scaling changes the scale of feature values while preserving the
useful information in the data.

## Why Do We Use Feature Scaling ?

Feature scaling is useful for several reasons:

-   **Prevent scale dominance:** Features with larger numerical values
    should not automatically dominate features with smaller values.
-   **Improve model performance:** Some machine learning algorithms work
    better when features are on comparable scales.
-   **Faster convergence:** Optimization algorithms such as Gradient
    Descent can converge more efficiently when features have comparable
    scales.
-   **Fair distance calculations:** Distance-based algorithms can be
    strongly affected by the scale of their input features.
-   **Improve numerical stability:** Keeping feature values within
    reasonable ranges can help avoid numerical issues in some
    algorithms.

Feature scaling is especially important for algorithms such as:

-   K-Nearest Neighbors (KNN)
-   K-Means Clustering
-   Support Vector Machines (SVM)
-   Principal Component Analysis (PCA)
-   Logistic Regression
-   Linear Regression trained using Gradient Descent
-   Neural Networks

Tree-based algorithms such as Decision Trees and Random Forests
generally do not require feature scaling because their splits are based
on feature thresholds rather than distances between values.

## Examples

### Example 1: Different Feature Scales

Suppose we have a dataset containing the following features:

  Feature                 Example value
  --------------------- ---------------
  Age                                25
  Annual income                 800,000
  Years of experience                 3

These features have very different numerical ranges. A distance-based
algorithm may be influenced much more by annual income because its
values are much larger.

Feature scaling brings the numerical features to comparable scales so
that the algorithm can consider them more fairly.

### Example 2: Why Scaling Matters for KNN

Imagine two people represented by their age and annual income:

-   Person A: Age = 25, Income = ₹500,000
-   Person B: Age = 26, Income = ₹510,000

KNN calculates distances between data points. The difference in income
is numerically much larger than the difference in age. Without scaling,
the income feature can dominate the distance calculation, even if age is
also important for the prediction.

After scaling, both features contribute on a more comparable scale to
the distance calculation.

### Example 3: Why Scaling Helps Gradient Descent

Suppose a model uses two features:

-   House size: values range from 500 to 3,000
-   Number of bedrooms: values range from 1 to 5

When feature scales differ substantially, the cost function can have an
elongated shape. Gradient Descent may take longer to reach the minimum.

Scaling the features can make optimization easier and help Gradient
Descent converge faster.

## Important Note

-   Fit the scaler using the **training data only**.
-   Use the fitted scaler to transform both the training data and the
    test data.
-   Do not fit the scaler separately on the test data, because this
    causes data leakage.
-   Apply scaling to numerical input features, not to the target
    variable by default.
-   The need for scaling depends on the machine learning algorithm being
    used.

## Types 

- Standardization (Z-Score Scaling)
- Normalization