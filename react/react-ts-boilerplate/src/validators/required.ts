const required = (value: any) => {
  if (!value.toString().trim().length) {
    return false;
  }
  return true;
};

export default required;
