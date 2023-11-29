import { categories } from './categories.const';

const extractValidIds = (categories) => {
  const mainCategoryIds = categories.mainCategory.map((cat) => cat.id);
  const subCategoryIds = categories.mainCategory.flatMap((cat) =>
    cat.subcategories.map((sub) => sub.id),
  );
  const minorCategoryIds = categories.mainCategory.flatMap((cat) =>
    cat.subcategories.flatMap((sub) =>
      sub.minorCategories.map((minor) => minor.id),
    ),
  );

  return {
    mainCategoryIds,
    subCategoryIds,
    minorCategoryIds,
  };
};

export const validIds = extractValidIds(categories);
