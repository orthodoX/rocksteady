import Moment from 'moment';
import React from 'react';
import _ from 'lodash';

import fetch from 'util/fetch';
import Image from './Image';

import {
  extractDeployedImage,
  fetchNomadStatus
} from 'components/NomadStatus/Data';

interface ImageListProps {
  endpoint: string;
  nomadStatusEndpoint: string;
  repositoryName: string;
  onSelect: (image: Image) => void;
  selectedImage?: Image;
}

interface ImageListState {
  loading: boolean;
  error: boolean;
  images: Image[];
  currentImageTag: string;
}

export default class ImageList extends React.Component<ImageListProps, ImageListState> {

  public state: ImageListState = {
    error: false,
    images: [],
    loading: true,
    currentImageTag: ''
  };

  public componentDidMount() {
    this.fetchData();
  }

  public render() {
    return (
      <div className='ImageList'>
        <h4>Available images</h4>
        { this.state.loading ? this.loadingMessage : this.content }
      </div>
    );
  }

  private get loadingMessage() {
    return <div className='ImageList-loadingMessage alert alert-secondary'>Loading images…</div>;
  }

  private get content() {
    if (this.state.error) return this.errorMessage;

    return (
      <div className='list-group'>
        { this.state.images.length ? this.imageRows : this.emptyRow }
      </div>
    );
  }

  private get errorMessage() {
    return <div className='ImageList-errorMessage alert alert-danger'>Error fetching data.</div>;
  }

  private get emptyRow() {
    return (
      <div className='list-group-item list-group-item-warning'>
        No images were found for the repository <strong>{ this.props.repositoryName }</strong>.
      </div>
    );
  }

  private get imageRows() {
    return this.state.images.map((image) => {
      const isActive = !!(this.props.selectedImage && this.props.selectedImage.id === image.id);
      const className = `list-group-item flex-column align-items-start ${ isActive ? 'active' : 'not-active'}`;
      const isDeployed = _.includes(image.tags, this.state.currentImageTag);

      return (
        <div className={ className } key={ image.id } onClick={ () => this.props.onSelect(image) }>
          { isDeployed ? <div className="mb-2"><span className="badge badge-success">currently deployed</span></div> : null }
          <div className='d-flex w-100 justify-content-between align-items-start mb-2'>
            <span className='tags d-flex flex-wrap'>{ this.taggify(image.tags, isActive) }</span>
            <small>{ image.timestamp.locale('en-gb').calendar() }</small>
          </div>
          <small>{ image.fileSize }</small>
        </div>
      );
    });
  }

  private taggify(tags: string[], isActive: boolean) {
    return tags.map((tag) =>
      <span key={ tag } className={ `badge ${isActive ? 'badge-light' : 'badge-primary'}` }>{ tag }</span>,
    );
  }

  private async fetchData() {
    try {
      const images = await this.fetchImageList();
      const currentImageTag = await this.fetchDeployedImageTag();

      this.setState({ loading: false, images, currentImageTag });
    } catch (_) {
      this.setState({ error: true, loading: false });
    }
  }

  private async fetchImageList() {
    const data = await fetch(this.props.endpoint);
    const json = await data.json();
    return json.map((d: { [s: string]: any }) => new Image(d));
  }

  private async fetchDeployedImageTag() {
    const nomadStatus = await fetchNomadStatus(this.props.nomadStatusEndpoint);
    const currentImage = extractDeployedImage(nomadStatus) || '';
    return _.last(currentImage.split(':')) || '';
  }
}
