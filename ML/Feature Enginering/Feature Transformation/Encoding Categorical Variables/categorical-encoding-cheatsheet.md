# Encoding Categorical Variables

## 1. What is categorical variable encoding?

A categorical variable contains values that represent groups or labels rather than continuous numerical measurements.

Examples:

| Feature | Example categories | Type |
|---|---|---|
| `gender` | Male, Female | Nominal |
| `fuel` | Petrol, Diesel, CNG | Nominal |
| `education` | School, UG, PG | Ordinal |
| `rating` | Poor, Average, Good | Ordinal |
| `purchased` | Yes, No | Binary target |

Most machine-learning algorithms work with numerical input. **Categorical encoding** converts categories into numerical representations so that an algorithm can process them.

> Important: Do not assign numbers to categories blindly. The encoding method should match the meaning of the feature.

---

## 2. Types of categorical variables

### Nominal variables

Categories have **no natural order**.

Examples: colour, city, fuel type, brand.

- Red is not greater than Blue.
- Petrol is not greater than Diesel.
- Avoid encoding nominal categories as `0, 1, 2` when that could make a model interpret them as ordered values.

### Ordinal variables

Categories have a **meaningful order**.

Examples: education level, satisfaction rating, size.

- Poor < Average < Good
- School < UG < PG
- The order should be defined using domain knowledge.

### Binary variables

A feature has only two categories.

Examples: Yes/No, True/False, Purchased/Not Purchased.

A binary variable can often be represented with two values, such as `0` and `1`. Make the mapping explicit and consistent.

---

## 3. Encoding methods — quick reference

| Method | How it works | Suitable for | Main caution |
|---|---|---|---|
| Label Encoding | Assigns an integer to each class label | Target variable (`y`) | Integer IDs do not represent rank |
| Ordinal Encoding | Maps ordered categories to ordered integers | Ordinal input features (`X`) | Define the correct order |
| One-Hot Encoding | Creates a separate 0/1 column for each category | Nominal input features | Can create many columns |
| Frequency / Count Encoding | Replaces a category with its frequency or count | High-cardinality nominal features | Different categories can get the same value |
| Binary Encoding | Converts category IDs into binary digits across columns | High-cardinality features | Less directly interpretable |
| Target Encoding | Replaces categories with a target-derived statistic | High-cardinality features, with careful validation | High risk of target leakage and overfitting |

This project currently has dedicated notebooks for **Ordinal and Label Encoding** and **One-Hot Encoding**. The other methods are included here as a broader reference.

---

## 4. The methods covered in this folder

### A. Ordinal Encoding

Converts categories into integers while preserving a specified order.

Example mapping:

| Category | Encoded value |
|---|---:|
| Poor | 0 |
| Average | 1 |
| Good | 2 |

Scikit-learn:

```python
from sklearn.preprocessing import OrdinalEncoder

categories = [['Poor', 'Average', 'Good']]
encoder = OrdinalEncoder(categories=categories)

X_train_encoded = encoder.fit_transform(X_train[['review']])
X_test_encoded = encoder.transform(X_test[['review']])
```

**Use when:** the categories have a genuine, known order.

**Avoid when:** categories are nominal and have no natural ranking.

### B. Label Encoding

Converts target class names into integer class identifiers.

Example mapping:

| Target label | Encoded value |
|---|---:|
| No | 0 |
| Yes | 1 |

Scikit-learn:

```python
from sklearn.preprocessing import LabelEncoder

label_encoder = LabelEncoder()
y_train_encoded = label_encoder.fit_transform(y_train)
y_test_encoded = label_encoder.transform(y_test)
```

**Use when:** encoding a one-dimensional classification target (`y`).

**Remember:** the numbers are class identifiers, not measurements or rankings. For input feature columns, generally choose an encoder designed for features, such as `OneHotEncoder` or `OrdinalEncoder`.

### C. One-Hot Encoding

Creates one binary column for each category.

Example for `fuel`:

| fuel | fuel_CNG | fuel_Diesel | fuel_Petrol |
|---|---:|---:|---:|
| CNG | 1 | 0 | 0 |
| Diesel | 0 | 1 | 0 |
| Petrol | 0 | 0 | 1 |

Pandas:

```python
import pandas as pd

df_encoded = pd.get_dummies(
    df,
    columns=['fuel'],
    dtype=int
)
```

Scikit-learn:

```python
from sklearn.preprocessing import OneHotEncoder

encoder = OneHotEncoder(handle_unknown='ignore')

X_train_encoded = encoder.fit_transform(X_train[['fuel']])
X_test_encoded = encoder.transform(X_test[['fuel']])
```

**Use when:** categories are nominal and the number of distinct categories is manageable.

**Remember:** Scikit-learn's encoder returns sparse output by default. Keeping it sparse can save memory for wide feature matrices.

---

## 5. `drop_first` and the dummy variable trap

For a feature with \(k\) categories, full one-hot encoding creates \(k\) columns. For some linear models with an intercept, these columns are perfectly linearly dependent because exactly one category is active in each row.

Dropping one category leaves \(k-1\) columns:

```python
pd.get_dummies(df, columns=['fuel'], drop_first=True, dtype=int)
```

or:

```python
OneHotEncoder(drop='first')
```

The dropped category becomes the **reference category**. When all remaining dummy columns for that feature are zero, the row belongs to that reference category.

- This can help avoid perfect multicollinearity in linear models with an intercept.
- It is not required for every algorithm.
- Tree-based models generally do not need a category dropped for this reason.
- Keep the same dropped-category mapping in training and inference.

---

## 6. Handling rare categories

A feature with many unique categories is called a **high-cardinality feature**. One-hot encoding it can create a very large number of columns.

One approach is to group infrequent categories into a shared category such as `Other` or `uncommon`.

Example using Pandas:

```python
counts = X_train['brand'].value_counts()
rare_categories = counts[counts < 100].index

X_train['brand_grouped'] = X_train['brand'].where(
    ~X_train['brand'].isin(rare_categories),
    'uncommon'
)
```

**Important:** learn the rare-category list from training data only. Apply that same list to validation, test, and future data. Also define how unseen categories will be handled.

The threshold is dataset-dependent; `100` is only an example, not a universal value.

---

## 7. Which encoding method should I choose?

| Situation | Suggested starting point |
|---|---|
| Ordered categories such as Low, Medium, High | Ordinal Encoding |
| Nominal categories such as colour or fuel type | One-Hot Encoding |
| Classification target labels | Label Encoding |
| Many categories with rare values | Group rare categories, then encode |
| High-cardinality feature | Consider frequency, binary, or carefully validated target encoding |
| Only two categories | Explicit 0/1 mapping or One-Hot Encoding |

These are starting points, not strict rules. The best representation can depend on the algorithm, dataset size, cardinality, and domain meaning.

---

## 8. Correct preprocessing workflow

A safe general workflow is:

1. Identify categorical columns.
2. Decide whether each feature is nominal, ordinal, or binary.
3. Separate input features (`X`) and target (`y`).
4. Split the data into training and test sets.
5. Fit feature encoders using **training data only**.
6. Transform training and test data using the same fitted encoders.
7. Handle categories that were not seen during fitting.
8. Train the model and evaluate it on the held-out test data.
9. Save the fitted preprocessing steps with the model for future predictions.

For a Scikit-learn workflow, a `ColumnTransformer` and `Pipeline` can keep preprocessing and model training together.

### Common mistakes to avoid

- Using ordinal integer codes for nominal categories without considering the model's interpretation.
- Fitting an encoder separately on training and test sets.
- Using the test set to decide rare categories or target-encoding statistics.
- Forgetting to handle categories that appear only in future data.
- Creating a huge dense one-hot matrix unnecessarily.
- Encoding the target and input features with the same method by habit.
- Assuming `drop_first=True` is always required.

---

## 9. Quick Scikit-learn reference

| Class / function | Purpose |
|---|---|
| `OrdinalEncoder` | Encode ordinal input features |
| `LabelEncoder` | Encode target class labels |
| `OneHotEncoder` | Encode nominal input features |
| `ColumnTransformer` | Apply different transformations to different columns |
| `Pipeline` | Chain preprocessing and an estimator into one workflow |

Useful attributes and parameters:

- `categories`: explicitly specify category levels and order.
- `drop='first'`: drop one one-hot category per feature.
- `handle_unknown='ignore'`: avoid an error for unseen categories during transform.
- `get_feature_names_out()`: inspect the generated feature names for supported transformers.

---

## 10. Key takeaways

- Encoding converts categorical values into a numerical form that machine-learning algorithms can use.
- First identify whether a variable is nominal, ordinal, or binary.
- Use **Ordinal Encoding** when a real category order exists.
- Use **One-Hot Encoding** for nominal input features when cardinality is manageable.
- Use **Label Encoding** for target class labels, not as a default for nominal input features.
- Fit preprocessing on training data and reuse it consistently.
- Consider rare-category grouping or other encodings when one-hot encoding would create too many columns.

## Folder notebooks

- `ordinal-and-label-encoding.ipynb` — ordinal input features and classification target labels.
- `onehot-encoding-notes.ipynb` — Pandas and Scikit-learn one-hot encoding, plus rare-category grouping.
