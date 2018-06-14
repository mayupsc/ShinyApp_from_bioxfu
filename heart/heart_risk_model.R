heart <- read.table('heart.dat')
names(heart) <- c("AGE", "SEX", "CHESTPAIN", "RESTBP", "CHOL",
                  "SUGAR", "ECG", "MAXHR", "ANGINA", "DEP", "EXERCISE", "FLUOR",
                  "THAL", "OUTPUT")

heart$CHESTPAIN <- factor(heart$CHESTPAIN)
heart$ECG <- factor(heart$ECG)
heart$THAL <- factor(heart$THAL)
heart$EXERCISE <- factor(heart$EXERCISE)
heart$OUTPUT <- heart$OUTPUT - 1

library(caret)
set.seed(987954)
heart_sampling_vector <- createDataPartition(heart$OUTPUT, p = 0.85, list = FALSE)
heart_train <- heart[heart_sampling_vector,]
heart_train_labels <- heart$OUTPUT[heart_sampling_vector]
heart_test <- heart[-heart_sampling_vector,]
heart_test_labels <- heart$OUTPUT[-heart_sampling_vector]

heart_model <- glm(OUTPUT ~ ., data = heart_train, family = binomial("logit"))
summary(heart_model)

train_predictions <- predict(heart_model, newdata = heart_train, type = "response")
train_class_predictions <- as.numeric(train_predictions > 0.5)
mean(train_class_predictions == heart_train$OUTPUT)

test_predictions = predict(heart_model, newdata = heart_test, type = "response")
test_class_predictions = as.numeric(test_predictions > 0.5)
mean(test_class_predictions == heart_test$OUTPUT)

save(heart, heart_model, file='heart_model.RData')
