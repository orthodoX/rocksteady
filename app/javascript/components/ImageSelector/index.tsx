import { hot } from 'react-hot-loader';

import React from 'react';

import Image from './Image';
import ImageDeployer from './ImageDeployer';
import ImageList from './ImageList';

interface ImageSelectorProps {
  deployEndpoint: string;
  imageListEndpoint: string;
  nomadStatusEndpoint: string;
  repositoryName: string;
  deployButtonProps: {
    html_classes: string[],
    label: string
  };
  defaultFilters: {
    filter_main: boolean,
    filter_latest: boolean
  }
}

interface ImageSelectorState {
  selectedImage?: Image;
}

class ImageSelector extends React.Component<ImageSelectorProps, ImageSelectorState> {
  public state = {
    selectedImage: undefined,
  };

  public render() {
    return (
      <div className='ImageSelector'>
        <div className='row'>
          <div className='col'>
            <ImageList
              endpoint={ this.props.imageListEndpoint }
              nomadStatusEndpoint={ this.props.nomadStatusEndpoint }
              repositoryName={ this.props.repositoryName }
              selectedImage={ this.state.selectedImage }
              onSelect={ this.onSelectImage }
              isMainOnlyDefault={ this.props.defaultFilters.filter_main }
              isLatestOnlyDefault={ this.props.defaultFilters.filter_latest }
            />
          </div>
          <div className='col'>
            <ImageDeployer
              endpoint={ this.props.deployEndpoint }
              selectedImage={ this.state.selectedImage }
              deployButtonProps={ this.props.deployButtonProps }
            />
          </div>
        </div>
      </div>
    );
  }

  private onSelectImage = (image: Image) => {
    if (this.state.selectedImage === image) {
      this.setState({ selectedImage: undefined });
    } else {
      this.setState({ selectedImage: image });
    }
  }
}

export default hot(module)(ImageSelector);
