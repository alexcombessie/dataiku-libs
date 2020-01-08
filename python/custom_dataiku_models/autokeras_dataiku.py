import pandas as pd
import numpy as np

from sklearn.base import BaseEstimator, RegressorMixin, ClassifierMixin
from autokeras import StructuredDataClassifier, StructuredDataRegressor

class AutoKerasClassifier(StructuredDataClassifier, BaseEstimator, ClassifierMixin):
    def __init__(self,
        column_names = None,
        column_types = None,
        num_classes = None,
        multi_label = False,
        loss = None,
        metrics = None,
        name = 'structured_data_classifier',
        max_trials = 100,
        directory = None,
        objective = 'val_accuracy',
        overwrite = True,
        seed = None,
        classes_ = None,
        epochs = None,
        batch_size = 32):
        super().__init__(
            column_names = column_names,
            column_types = column_types,
            num_classes = num_classes,
            multi_label = multi_label,
            loss = loss,
            metrics = metrics,
            name = name,
            max_trials = max_trials,
            directory = directory,
            objective = objective,
            overwrite = overwrite,
            seed = seed)
        self.classes_ = classes_
        self.epochs = epochs
        self.batch_size = batch_size

    def fit(self, x = None, y = None, epochs = None, callbacks = None, validation_split = 0.2, **kwargs):
        self.classes_ = [str(i) for i in np.unique(y)]
        super().fit(x = x, y = y, epochs = self.epochs, callbacks = callbacks,
                       validation_split = validation_split, batch_size = self.batch_size, **kwargs)

    def predict(self, x, **kwargs):
        preds = super().predict(x = x, batch_size = self.batch_size, **kwargs)
        y = pd.Series(preds.flatten())
        return(y)

class AutoKerasRegressor(StructuredDataRegressor, BaseEstimator, RegressorMixin):
    def __init__(self,
        column_names = None,
        column_types = None,
        output_dim = None,
        loss = 'mean_squared_error',
        metrics = None,
        name = 'structured_data_regressor',
        max_trials = 100,
        directory = None,
        objective = 'val_loss',
        overwrite = True,
        seed = None,
        epochs = None,
        batch_size = 32):
        super().__init__(
            column_names = column_names,
            column_types = column_types,
            output_dim = output_dim,
            loss = loss,
            metrics = metrics,
            name = name,
            max_trials = max_trials,
            directory = directory,
            objective = objective,
            overwrite = overwrite,
            seed = seed)
        self.epochs = epochs
        self.batch_size = batch_size

    def fit(self, x = None, y = None, epochs = None, callbacks = None, validation_split = 0.2, **kwargs):
        super().fit(x = x, y = y, epochs = self.epochs, callbacks = callbacks,
                       validation_split = validation_split, batch_size = self.batch_size, **kwargs)
