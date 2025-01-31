library(caret)
library(readxl)
library(openxlsx)
library(ggplot2)
library(pROC)

# Load biomarker combinations from provided Excel files
modelo1 <- read_excel("path/to/modelo1.xlsx")
modelo2 <- read_excel("path/to/modelo2.xlsx")

# Define covariate and response variable
covariate <- c("BMI")  # Covariate to adjust for
response_variable <- "Grupo"  # Dependent variable

# Combine the two models
combinations <- list(modelo1, modelo2)

for (i in 1:length(combinations)) {
  
  explanatory_variables <- trimws(combinations[[i]]$Biomarcadores)
  
  # Prepare dataset
  model_data <- combinations[[i]][, c(response_variable, explanatory_variables, covariate)]
  model_data <- na.omit(model_data)  # Remove missing values
  
  # Normalize features
  preprocess_params <- preProcess(model_data[, c(explanatory_variables, covariate)], method = c("center", "scale"))
  normalized_data <- predict(preprocess_params, model_data[, c(explanatory_variables, covariate)])
  normalized_data <- cbind(Grupo = model_data$Grupo, normalized_data)
  
  # Recode response variable
  normalized_data$Grupo <- factor(normalized_data$Grupo, levels = c(0, 1, 2), labels = c("X0", "X1", "X2"))
  residuals_data <- data.frame(Grupo = normalized_data$Grupo)
  
  # Compute residuals adjusting for covariate
  for (var in explanatory_variables) {
    formula <- as.formula(paste(var, "~", covariate))
    model <- lm(formula, data = normalized_data)
    residuals_data[[var]] <- residuals(model)
  }
  
  # Train-test split (80-20%)
  set.seed(123)
  train_index <- createDataPartition(residuals_data$Grupo, p = 0.8, list = FALSE)
  train_data <- residuals_data[train_index, , drop = FALSE]
  test_data <- residuals_data[-train_index, , drop = FALSE]
  
  # Balance training data via oversampling
  set.seed(123)
  over_x0 <- train_data[train_data$Grupo == "X0", ]
  over_x2 <- train_data[train_data$Grupo == "X2", ]
  over_x0 <- over_x0[sample(1:nrow(over_x0), size = 136, replace = TRUE), ]
  over_x2 <- over_x2[sample(1:nrow(over_x2), size = 136, replace = TRUE), ]
  under_x1 <- train_data[train_data$Grupo == "X1", ]
  balanced_train_data <- rbind(over_x0, under_x1, over_x2)
  
  # Set up cross-validation
  control <- trainControl(
    method = "cv",
    number = 10,
    classProbs = TRUE,
    summaryFunction = multiClassSummary
  )
  
  # Define tuning grid for Elastic Net
  tune_grid <- expand.grid(
    alpha = seq(0, 1, by = 0.1),
    lambda = 10^seq(-4, 1, length = 100)
  )
  
  # Train Elastic Net model
  set.seed(123)
  elastic_net_model <- train(
    Grupo ~ .,
    data = balanced_train_data,
    method = "glmnet",
    trControl = control,
    tuneGrid = tune_grid
  )
  
  # Extract best model and coefficients
  best_model <- elastic_net_model$finalModel
  best_lambda <- elastic_net_model$bestTune$lambda
  coefficients <- coef(best_model, s = best_lambda)
  
  # Evaluate model on test set
  predictions <- predict(elastic_net_model, newdata = test_data)
  conf_matrix <- confusionMatrix(predictions, test_data$Grupo)
  accuracy <- conf_matrix$overall["Accuracy"]
  
  # Compute AUC
  probabilities <- predict(elastic_net_model, newdata = test_data, type = "prob")
  colnames(probabilities) <- levels(test_data$Grupo)
  test_data$Grupo <- factor(test_data$Grupo, levels = levels(train_data$Grupo))
  roc_obj <- multiclass.roc(test_data$Grupo, probabilities)
  auc_value <- roc_obj$auc
  
  # Save results if accuracy threshold is met
  if (accuracy > 0.65) {
    output_file <- paste0("results_model_", i, ".txt")
    sink(output_file)
    cat("### Elastic Net Model - Results ###\n\n")
    print(elastic_net_model)
    cat("\n### Best Parameters ###\n\n")
    print(elastic_net_model$bestTune)
    
    cat("\n### Coefficients per Group ###\n\n")
    if (is.list(coefficients)) {
      for (group in names(coefficients)) {
        cat("Group:", group, "\n")
        print(as.matrix(coefficients[[group]]))
        cat("\n")
      }
    } else {
      cat("Binary model or single coefficient set:\n")
      print(as.matrix(coefficients))
    }
    
    cat("\n### Confusion Matrix ###\n\n")
    print(conf_matrix)
    
    cat("\n### Evaluation Metrics ###\n")
    cat("Accuracy:", accuracy, "\n")
    cat("AUC:", auc_value, "\n")
    sink()
    
    print(paste("Model", i, "processed and results saved in", output_file))
  } else {
    print(paste("Model", i, "processed but accuracy is below 0.65 (", accuracy, ")"))
  }
}

print("Analysis completed for both models.")
