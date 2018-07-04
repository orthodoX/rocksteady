import { hot } from 'react-hot-loader';

import React from 'react';

import Image from './Image';
import ImageDeployer from './ImageDeployer';
import ImageList from './ImageList';

interface ImageSelectorProps {
  deployEndpoint: string;
  imageListEndpoint: string;
  repositoryName: string;
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
              repositoryName={ this.props.repositoryName }
              selectedImage={ this.state.selectedImage }
              onSelect={ this.onSelectImage }
            />
          </div>
          <div className='col'>
            <ImageDeployer
              endpoint={ this.props.deployEndpoint }
              selectedImage={ this.state.selectedImage }
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
